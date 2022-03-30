import re
import sys
import platform
import inspect
from pathlib import Path
import os
from time import sleep
from multiprocessing import Process, freeze_support
from filelock import FileLock
from socket import socket, AF_INET, IPPROTO_TCP, SOCK_STREAM, SHUT_RD
from TeproApi import TeproApi
from TeproAlgo import TeproAlgo


def startMLPLAProcess(port):
    # JRE 15 has to be in PATH!
    # This is the child which never returns.
    jarPath = Path("ttsops") / "MLPLAServer" / \
        "MLPLAServer-0.0.1-SNAPSHOT-jar-with-dependencies.jar"
    os.execlp("java", "java", "-jar", str(jarPath), str(port))

# Author: Radu ION, (C) ICIA 2020
# To be included in the TEPROLIN platform.
# Always run Teprolin from the 'PyTEPRO' or 'teprolin' or 'TEPROLIN' folder!
class TTSOps(TeproApi):
    """This is the MLPLAServer in Java, exposed as a TEPROLIN application.
    See the README.md for additional information about MLPLA."""

    # Get port numbers from this file; if multiple processes
    # are started by e.g. Flask, each one will have a different port.
    mlplaPortFile = "mlpla-port.txt"
    mlplaPortLockFile = "mlpla-port.txt.lock"
    # Exit command: signal the MLPLAServer process it should
    # gracefully exit. Leave the \n in there, as it
    # flushes the socket!
    exitCommand = "#EXIT#\n"
    # End-of-transmission command: signal the MLPLA process
    # it should start processing.
    eotCommand =  "#EOT#\n"
    eotRegex = re.compile(r'#EOT#\r?\n$')

    def __init__(self):
        super().__init__()
        self._algoName = TeproAlgo.algoTTS
        self._mlplaPort = self._getMLPLAPort()

    def _getMLPLAPort(self) -> int:
        port = 12001
        lock = FileLock(TTSOps.mlplaPortLockFile)

        with lock:
            with open(TTSOps.mlplaPortFile, mode="r") as f:
                port = int(f.readline().strip())
            # end with open r

            print("PID {0}-{1}.{2}[{3}]: got MLPLA port of {4}".
                  format(
                      os.getpid(),
                      Path(inspect.stack()[0].filename).stem,
                      inspect.stack()[0].function,
                      inspect.stack()[0].lineno,
                      port
                  ), file=sys.stderr, flush=True)

            with open(TTSOps.mlplaPortFile, mode="w") as f:
                if port == 12001:
                    print("12010", file=f, flush=True)
                else:
                    print(str(port + 1), file=f, flush=True)
            # end with open w
        # end with lock

        return port

    def createApp(self):
        # Call freeze_support() first in Windows...
        if platform.system() == "Windows":
            freeze_support()

        Process(target=startMLPLAProcess, args=[
                self._mlplaPort], daemon=True).start()

        # Wait for MLPLA process to start...
        s = socket(family=AF_INET, type=SOCK_STREAM, proto=IPPROTO_TCP)
        connected = False

        while not connected:
            try:
                s.connect(("localhost", self._mlplaPort))
                connected = True
            except OSError as err:
                print("{0}.{1}[{2}]: connecting to server failed with '{3}'".
                      format(
                          Path(inspect.stack()[0].filename).stem,
                          inspect.stack()[0].function,
                          inspect.stack()[0].lineno,
                          err.strerror
                      ), file=sys.stderr, flush=True)
                # Wait for the server to come online...
                sleep(5)

    def destroyApp(self):
        s = socket(family=AF_INET, type=SOCK_STREAM, proto=IPPROTO_TCP)
        s.connect(("localhost", self._mlplaPort))
        s.shutdown(SHUT_RD)
        s.send(TTSOps.exitCommand.encode(encoding='utf-8'))

    def _getSentenceAnnotation(self, text: str) -> list:
        # 1. Send text to MLPLA, in UTF-8 bytes
        s = socket(family=AF_INET, type=SOCK_STREAM, proto=IPPROTO_TCP)
        s.connect(("localhost", self._mlplaPort))

        # Very important: add \n to flush the socket!
        text += "\n"
        s.send(text.encode(encoding='utf-8'))
        # Send the 'end of transmission' command
        s.send(TTSOps.eotCommand.encode(encoding='utf-8'))

        # 2. Get annotated text from MLPLA, in UTF-8 bytes, 1024 bytes at a time.
        mlplaBytes = []
        b = s.recv(1024)

        while True:
            mlplaBytes.append(b)

            try:
                lastK = b''.join(mlplaBytes).decode(encoding='utf-8')
            except UnicodeDecodeError:
                # Maybe End Of Buffer in the middle of utf-8 encoding...
                b = s.recv(1024)
                continue
            # end try

            if TTSOps.eotRegex.search(lastK):
                break
            # end if

            b = s.recv(4096)
        # end while

        # 3. Extract annotated info from the returned text.
        # Ignore utf-8 decoding errors
        mlplaText = b''.join(mlplaBytes).decode(encoding='utf-8', errors='ignore')
        mlplaLines = re.split(r'\r?\n', mlplaText)
        result = []

        for line in mlplaLines:
            if not line:
                break
            
            parts = line.split(sep='\t')
            result.append((parts))

        return result

    def _runApp(self, dto, opNotDone):
        if (TeproAlgo.getTokenizationOperName() in opNotDone):
            # Tokenization is required for MLPLAServer to work
            return dto

        for i in range(dto.getNumberOfSentences()):
            tsent = dto.getSentenceTokens(i)
            wforms = []

            for tok in tsent:
                wforms.append(tok.getWordForm())

            msent = self._getSentenceAnnotation(" ".join(wforms))

            if len(msent) == len(tsent):
                for j in range(len(msent)):
                    orig = tsent[j]
                    mtok = msent[j]

                    if orig.getWordForm() == mtok[0]:
                        if mtok[1] != '_' and \
                            (TeproAlgo.getHyphenationOperName() in opNotDone or \
                                TeproAlgo.getStressIdentificationOperName() in opNotDone):
                            orig.setSyllables(mtok[1])
                        
                        if mtok[2] != '_' and TeproAlgo.getPhoneticTranscriptionOperName() in opNotDone:
                            orig.setPhonetical(mtok[2])

                        if mtok[3] != '_' and \
                            (TeproAlgo.getNumeralRewritingOperName() in opNotDone or \
                                TeproAlgo.getAbbreviationRewritingOperName() in opNotDone):
                            orig.setExpansion(mtok[3])
                    # end if word forms match
                # end all tokens
            # end if sentence lengths match
        # end all found sentences

        return dto

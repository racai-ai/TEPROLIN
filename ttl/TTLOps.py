import re
import sys
import platform
import inspect
from pathlib import Path
from time import sleep
import os
from time import sleep
import unicodedata as uc
from multiprocessing import Process, freeze_support
from filelock import FileLock
from socket import socket, AF_INET, IPPROTO_TCP, SOCK_STREAM, SHUT_RD
from TeproApi import TeproApi
from TeproAlgo import TeproAlgo
from TeproTok import TeproTok


def startTTLProcess(port):
    # Perl has to be in PATH!
    # This is the child which never returns.
    os.execlp("perl", "perl", "TeproTTL.pl", str(port))

# Author: Radu ION, (C) ICIA 2018
# To be included in the TEPROLIN platform.
# See http://www.racai.ro/media/WSD.pdf, Chapter 2.
# Always run Teprolin from the 'PyTEPRO' or 'teprolin' or 'TEPROLIN' folder!
class TTLOps(TeproApi):
    """This is the first non-Python NLP app to be included in the
    TEPROLIN platform. It's the TTL Perl module, adapted for TEPROLIN."""

    # Get port numbers from this file; if multiple processes
    # are started by e.g. Flask, each one will have a different
    # port.
    ttlPortFile = "ttl-port.txt"
    ttlPortLockFile = "ttl-port.txt.lock"
    # Exit command: signal the TTL process it should
    # gracefully exit. Leave the \n in there, as it
    # flushes the socket!
    exitCommand = "#EXIT#\n"
    # End-of-transmission command: signal the TTL process
    # it should start processing.
    eotCommand = "#EOT#\n"
    lemmaProbRX = re.compile("^\\(.+?\\)")

    def __init__(self):
        super().__init__()
        self._algoName = TeproAlgo.algoTTL
        self._ttlPort = self._getTTLPort()

    def _getTTLPort(self) -> int:
        port = 2001
        lock = FileLock(TTLOps.ttlPortLockFile)

        with lock:
            with open(TTLOps.ttlPortFile, mode="r") as f:
                port = int(f.readline().strip())
            # end with open r

            print("PID {0}-{1}.{2}[{3}]: got TTL port of {4}".
                  format(
                      os.getpid(),
                      Path(inspect.stack()[0].filename).stem,
                      inspect.stack()[0].function,
                      inspect.stack()[0].lineno,
                      port
                  ), file=sys.stderr, flush=True)

            with open(TTLOps.ttlPortFile, mode="w") as f:
                if port == 2001:
                    print("2010", file=f, flush=True)
                else:
                    print(str(port + 1), file=f, flush=True)
            # end with open w
        # end with lock

        return port

    def createApp(self):
        """TODO: It would be better to launch the TTL process
        in a different script, as this one duplicates approx. 1.7GB of
        data in memory..."""

        # Call freeze_support() first in Windows...
        if platform.system() == "Windows":
            freeze_support()

        Process(target=startTTLProcess, args=[
                self._ttlPort], daemon=True).start()

        # Wait for TTL process to start...
        s = socket(family=AF_INET, type=SOCK_STREAM, proto=IPPROTO_TCP)
        connected = False

        while not connected:
            try:
                s.connect(("localhost", self._ttlPort))
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
        s.connect(("localhost", self._ttlPort))
        s.shutdown(SHUT_RD)
        s.send(TTLOps.exitCommand.encode(encoding='utf-8'))

    def _runApp(self, dto, opNotDone):
        text = dto.getText()

        # 1. Send text to TTL, in UTF-8 bytes
        s = socket(family=AF_INET, type=SOCK_STREAM, proto=IPPROTO_TCP)
        s.connect(("localhost", self._ttlPort))

        # Very important: add \n to flush the socket!
        text += "\n"
        s.send(text.encode(encoding='utf-8'))
        # Send the 'end of transmission' command
        s.send(TTLOps.eotCommand.encode(encoding='utf-8'))

        # 2. Get annotated text from TTL, in UTF-8 bytes,
        # 1024 bytes at a time.
        ttlBytes = []
        b = s.recv(1024)

        while b != b'':
            ttlBytes.append(b)
            b = s.recv(1024)

        # 3. Extract annotated info from the returned text.
        ttlText = b''.join(ttlBytes).decode('utf-8')
        ttlSentences = ttlText.split(sep='\n\n')
        sid = 0

        for ts in ttlSentences:
            ts = ts.strip()
            ttlTokens = ts.split('\n')
            idx = 0
            # Teprolin tokenized sentence
            ttsent = []
            # Teprolin string sentence
            tssent = ""

            for tt in ttlTokens:
                tp = tt.split()
                word = tp[0]
                ctag = tp[1]
                msd = tp[2]
                lem = tp[3]

                if TTLOps.lemmaProbRX.match(lem) != None:
                    lem = TTLOps.lemmaProbRX.sub("", lem, 1)

                if ',' in msd:
                    msd = msd.split(',')[0]

                chk = tp[4]

                tt = TeproTok()

                idx += 1
                tt.setId(idx)
                tt.setWordForm(word)
                tt.setCTAG(ctag)
                tt.setMSD(msd)
                tt.setLemma(lem)

                if chk != '_':
                    tt.setChunk(chk)

                ttsent.append(tt)

                if not tssent:
                    tssent += word
                elif word in ",;.!?-)}]”'\"`":
                    tssent += word
                elif tssent[-1] in "'\"-`„({[" and uc.category(word[0]).startswith("L"):
                    tssent += word
                else:
                    tssent += " " + word
            # end for tt

            if not dto.isOpPerformed(TeproAlgo.getSentenceSplittingOperName()):
                dto.addSentenceString(tssent)
                dto.addSentenceTokens(ttsent)
            else:
                # Check and update annotations that only TTL
                # can produce or that are requested specifically from it.
                alignment = dto.alignSentences(ttsent, sid)

                for op in opNotDone:
                    dto.copyTokenAnnotation(ttsent, sid, alignment, op)

            sid += 1
        # end for ts

        return dto

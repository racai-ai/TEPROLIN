import atexit
import inspect
import sys
import os
import requests, zipfile, io
from pathlib import Path
from time import gmtime
from filelock import FileLock
from enum import Enum

from TeproAlgo import TeproAlgo
from TeproDTO import TeproDTO

# Import all NLP apps that are implemented
from tnorm.TextNorm import TextNorm
from diac.DiacRestore import DiacRestore
from cubenlp.CubeNLP import CubeNLP
from udpipe.UDPipe import UDPipe
from ttsops.TTSOps import TTSOps
from ttl.TTLOps import TTLOps
from ner.NEROps import NEROps
from bioner.BioNEROps import BioNEROps
from TeproConfig import TEPROLIN_RESOURCES_FOLDER, DIACMODELFILE

# Statistic status


class SStatus(Enum):
    # Read from file
    EXISTING = 1
    # Produced during runtime
    ACQUIRED = 2


CONSTSTR1 = "' is not recognized. See class TeproAlgo."
CONSTSTR2 = "NLP app '"

# Author: Radu ION, (C) ICIA 2018-2020


class Teprolin(object):
    """This is the TEPROLIN platform that integrates all of the exposed
    NLP apps and provides them as TeproApi objects.
    The user only has to specify what operations he/she wants and, with each
    NLP op, the algorithm to perform the op."""

    statsFile = "teprolin-stats.txt"
    statsLockFile = "teprolin-stats.txt.lock"
    statsYear = "year"
    statsMonth = "month"
    statsDay = "day"
    statsTokens = "tokens"
    statsRequests = "requests"
    # After how many requests to update
    # the stats file such that the brother processes
    # can update.
    statsUpdateCounts = 10
    resourcesDownloadLink = "https://relate.racai.ro/resources/teprolin/teprolin-resources.zip"

    def _installResources(self):
        """This method will check for the existence of the .teprolin folder
        in the user's home folder. If there's no such folder, it is created
        and resources are downloaded from RACAI's servers."""
        teproFolder = Path(TEPROLIN_RESOURCES_FOLDER)

        if not teproFolder.is_dir():
            print("{0}.{1}[{2}]: creating the TEPROLIN resources folder {3}".
                    format(
                        Path(inspect.stack()[0].filename).stem,
                        inspect.stack()[0].function,
                        inspect.stack()[0].lineno,
                        TEPROLIN_RESOURCES_FOLDER
                    ), file=sys.stderr, flush=True)
            
            # Folder already exists in the .zip
            teproFolder.mkdir(mode=0o755)

            print("{0}.{1}[{2}]: downloading the resources @ {3}".
                    format(
                        Path(inspect.stack()[0].filename).stem,
                        inspect.stack()[0].function,
                        inspect.stack()[0].lineno,
                        Teprolin.resourcesDownloadLink
                    ), file=sys.stderr, flush=True)

            r = requests.get(Teprolin.resourcesDownloadLink)

            if r.status_code == 200:
                z = zipfile.ZipFile(io.BytesIO(r.content))
                z.extractall(teproFolder)

                if Path(DIACMODELFILE).is_file():
                    print("{0}.{1}[{2}]: installation OK".
                            format(
                                Path(inspect.stack()[0].filename).stem,
                                inspect.stack()[0].function,
                                inspect.stack()[0].lineno
                            ), file=sys.stderr, flush=True)
                else:
                    print("{0}.{1}[{2}]: expected file {3} wasn't found, please check".
                            format(
                                Path(inspect.stack()[0].filename).stem,
                                inspect.stack()[0].function,
                                inspect.stack()[0].lineno,
                                DIACMODELFILE
                            ), file=sys.stderr, flush=True)
                    exit(1)
            else:
                print("{0}.{1}[{2}]: could not download the resources @ {3}".
                        format(
                            Path(inspect.stack()[0].filename).stem,
                            inspect.stack()[0].function,
                            inspect.stack()[0].lineno,
                            Teprolin.resourcesDownloadLink
                        ), file=sys.stderr, flush=True)
                exit(1)

    def _startApps(self):
        """When you add a new NLP app, don't forget to add it here as well!"""
        self._installResources()

        tn = TextNorm()
        dr = DiacRestore()
        dr.loadResources()
        cb = CubeNLP()
        cb.createApp()
        cb.loadResources()
        udp = UDPipe()
        udp.loadResources()
        ttl = TTLOps()
        ttl.createApp()
        tts = TTSOps()
        tts.createApp()
        ner = NEROps()
        bner = BioNEROps()
        bner.createApp()

        return [tn, dr, cb, udp, ttl, tts, ner, bner]

    def _readStatsFile(self) -> list:
        lock = FileLock(Teprolin.statsLockFile)
        stats = []

        with lock:
            print("PID {0}-{1}.{2}[{3}]: reading the statistics from the file...".
                  format(
                      os.getpid(),
                      Path(inspect.stack()[0].filename).stem,
                      inspect.stack()[0].function,
                      inspect.stack()[0].lineno
                  ), file=sys.stderr, flush=True)

            with open(Teprolin.statsFile, mode="r") as f:
                for line in f:
                    parts = line.split()
                    date = (
                        int(parts[0]),
                        int(parts[1]),
                        int(parts[2])
                    )
                    tkc = int(parts[3])
                    rqc = int(parts[4])
                    sts = SStatus.EXISTING
                    stats.append([date, tkc, rqc, sts])
            # end with open
        # end with lock
        return stats

    def _writeStatsFile(self):
        toUpdate = False

        for st in self._stats:
            if st[3] == SStatus.ACQUIRED:
                toUpdate = True
                break

        if not toUpdate:
            return

        exstats = self._readStatsFile()
        lock = FileLock(Teprolin.statsLockFile)
        uprec = 0
        adrec = 0

        with lock:
            print("PID {0}-{1}.{2}[{3}]: updating the statistics in the file...".
                  format(
                      os.getpid(),
                      Path(inspect.stack()[0].filename).stem,
                      inspect.stack()[0].function,
                      inspect.stack()[0].lineno
                  ), file=sys.stderr, flush=True)

            with open(Teprolin.statsFile, mode="w") as f:
                for x in exstats:
                    for i in range(len(self._stats)):
                        y = self._stats[i]

                        if y[0] == x[0]:
                            if y[3] == SStatus.ACQUIRED:
                                x[1] += y[1]
                                x[2] += y[2]
                                uprec += 1
                            # end if ACQUIRED
                            self._stats.pop(i)
                            break
                        # end if same day
                    # end for i
                    d = x[0]
                    t = x[1]
                    r = x[2]
                    f.write(" ".join(str(e) for e in d))
                    f.write(" ")
                    f.write(str(t))
                    f.write(" ")
                    f.write(str(r))
                    f.write("\n")
                # end for x

                for y in self._stats:
                    if y[3] == SStatus.ACQUIRED:
                        d = y[0]
                        t = y[1]
                        r = y[2]
                        f.write(" ".join(str(e) for e in d))
                        f.write(" ")
                        f.write(str(t))
                        f.write(" ")
                        f.write(str(r))
                        f.write("\n")
                        adrec += 1
                # end for y
                print("PID {0}-{1}.{2}[{3}]: updated {4} records and added {5} records.".
                      format(
                          os.getpid(),
                          Path(inspect.stack()[0].filename).stem,
                          inspect.stack()[0].function,
                          inspect.stack()[0].lineno,
                          uprec,
                          adrec
                      ), file=sys.stderr, flush=True)
            # end with open

    def _indexOfAlgo(self, algo: str) -> int:
        """Given an algorithm name from TeproAlgo.getAvailableAlgorithms(),
        get the index of the corresponding TeproApi object from self._apps."""

        appi = -1

        for i in range(len(self._apps)):
            app = self._apps[i]

            if app.getAlgoName() == algo:
                appi = i
                break

        return appi

    def _checkApiUniqueNames(self):
        """Each TeproApi object must have a unique algorithm name."""

        for i in range(len(self._apps)):
            ain = self._apps[i].getAlgoName()

            for j in range(i + 1, len(self._apps)):
                ajn = self._apps[j].getAlgoName()

                if ain == ajn:
                    raise RuntimeError(CONSTSTR2 + ain +
                                       "' found twice in self._apps. Each TeproApi object must have a unique name!")

    def defaultConfiguration(self):
        # Dictionary of operations to implementing algorithms (NLP app).
        self._conf = {}

        for op in TeproAlgo.getAvailableOperations():
            self._conf[op] = TeproAlgo.getDefaultAlgoForOper(op)
            print("{0}.{1}[{2}]: configuring operation '{3}' with algorithm '{4}'".
                    format(
                        Path(inspect.stack()[0].filename).stem,
                        inspect.stack()[0].function,
                        inspect.stack()[0].lineno,
                        op,
                        self._conf[op]
                    ), file=sys.stderr, flush=True)

    def __init__(self):
        self._requests = 0
        self._stats = self._readStatsFile()
        self.defaultConfiguration()
        self._apps = self._startApps()
        self._checkApiUniqueNames()
        atexit.register(self._destroyAllApps)

    def getConfiguration(self, op: str = None):
        if op is None:
            # Just return the whole configuration
            return self._conf

        if op in self._conf:
            # Or return the configuration for op,
            # if not None
            return self._conf[op]
        else:
            return None

    def configure(self, op: str, algo: str):
        availableOps = TeproAlgo.getAvailableOperations()
        availableAlgos = TeproAlgo.getAvailableAlgorithms()

        if op not in availableOps:
            raise RuntimeError("Operation '" + op + CONSTSTR1)

        if algo not in availableAlgos:
            raise RuntimeError(CONSTSTR2 + algo + CONSTSTR1)

        if not TeproAlgo.canPerform(algo, op):
            raise RuntimeError(
                CONSTSTR2 + algo + "' cannot perform operation '" + op + "'. See class TeproAlgo.")

        print("{0}.{1}[{2}]: requesting operation '{3}' be performed with '{4}'".
              format(
                  Path(inspect.stack()[0].filename).stem,
                  inspect.stack()[0].function,
                  inspect.stack()[0].lineno,
                  op,
                  algo
              ), file=sys.stderr, flush=True)

        self._conf[op] = algo

    def pcFull(self, text: str) -> TeproDTO:
        """This is the complete processing chain (pc), executing
        all NLP ops enumerated in TeproAlgo."""

        # Just run everything we know about on text.
        return self.pcExec(text, TeproAlgo.getAvailableOperations())

    def pcDiac(self, text: str) -> str:
        """This processing chain will insert diacritics in a text
        which does not have them."""

        # You can specify the whole call chain, if you know it.
        return self.pcExec(text, [
            TeproAlgo.getTextNormOperName(),
            TeproAlgo.getDiacRestorationOperName()])

    def pcLemma(self, text: str) -> TeproDTO:
        """This processing chain will do POS tagging and lemmatization
        on the input text, splitting the text in sentences and tokens beforehand."""

        # Or you can specify a few operations like 'lemmatization',
        # pcExec will infer the dependencies.
        return self.pcExec(text, [TeproAlgo.getLemmatizationOperName()])

    def pcParse(self, text: str) -> TeproDTO:
        """This processing chain will do chunking and dependency parsing
        on the input text, splitting the text in sentences and tokens and
        doing POS tagging and lemmatization beforehand."""

        return self.pcExec(text, [TeproAlgo.getDependencyParsingOperName()])

    def pcExec(self, text: str, ops: list) -> TeproDTO:
        """This processing chain will make sure that the list of
        requested operations (ops) are executed on the input text,
        along with their required dependencies."""

        availableOps = TeproAlgo.getAvailableOperations()

        # 1. Check if all requested ops are valid
        for op in ops:
            if op not in availableOps:
                raise RuntimeError("Operation '" + op + CONSTSTR1)

        # 2. Increase the number of requests by 1
        # with every call to this method.
        self._requests += 1
        configuredApps = []

        # 2.1 Dynamically alter the configuration
        # depending on exceptions. For instance
        # ner-icia requires ttl-icia, not nlp-cube-adobe
        TeproAlgo.reconfigureWithStrictRequirements(self._conf)

        # 3.1 Resolve all operation dependencies
        expandedOps = TeproAlgo.resolveDependencies(ops)

        # 3.2 Get instantiated apps for the requested operations.
        # Apps are added in the order provided by expandedOps,
        # so no more app sorting is needed.
        for op in expandedOps:
            opi = self._indexOfAlgo(self._conf[op])

            if opi >= 0:
                app = self._apps[opi]

                if app not in configuredApps:
                    configuredApps.append(app)
            else:
                print("{0}.{1}[{2}]: operation '{3}' is not supported yet.".
                      format(
                          Path(inspect.stack()[0].filename).stem,
                          inspect.stack()[0].function,
                          inspect.stack()[0].lineno,
                          op
                      ), file=sys.stderr, flush=True)

        # 5. Run all configured NLP apps in sequence on
        # the dto object.
        dto = TeproDTO(text, self._conf)

        for app in configuredApps:
            print("{0}.{1}[{2}]: running NLP app '{3}'".
                  format(
                      Path(inspect.stack()[0].filename).stem,
                      inspect.stack()[0].function,
                      inspect.stack()[0].lineno,
                      app.getAlgoName()
                  ), file=sys.stderr, flush=True)
            dto = app.doWork(dto)

        # 6. Collect statistics
        ts = gmtime()

        if self._stats and \
                self._stats[-1][0][0] == ts.tm_mday and \
                self._stats[-1][0][1] == ts.tm_mon and \
                self._stats[-1][0][2] == ts.tm_year:
            self._stats[-1][1] += dto.getProcessedTokens()
            self._stats[-1][2] += 1
            self._stats[-1][3] = SStatus.ACQUIRED
        else:
            date = (ts.tm_mday, ts.tm_mon, ts.tm_year)
            tkc = dto.getProcessedTokens()
            self._stats.append(
                [date, tkc, self._requests, SStatus.ACQUIRED])

        # 7. Write stats every statsUpdateCounts requests
        if self._requests % Teprolin.statsUpdateCounts == 0:
            self._writeStatsFile()
            self._stats = self._readStatsFile()

        # 8. Work done, return the dto object.
        return dto

    def getStats(self, svalue: str, tvalue: str, hsize: int) -> list:
        # By default, tokens statistics are returned.
        sindex = 1
        stats = []

        if svalue == Teprolin.statsTokens:
            sindex = 1
        elif svalue == Teprolin.statsRequests:
            sindex = 2

        for i in range(len(self._stats) - 1, -1, -1):
            s = self._stats[i]
            dkey = ""

            if tvalue == Teprolin.statsYear:
                dkey = str(s[0][2])
            elif tvalue == Teprolin.statsMonth:
                dkey = "{0:02d}".format(s[0][1]) + "-" + str(s[0][2])
            elif tvalue == Teprolin.statsDay:
                dkey = "{0:02d}".format(
                    s[0][0]) + "-" + "{0:02d}".format(s[0][1]) + "-" + str(s[0][2])
            else:
                # By default, month stats
                dkey = "{0:02d}".format(s[0][1]) + "-" + str(s[0][2])

            freq = s[sindex]

            if stats and stats[-1][0] == dkey:
                stats[-1][1] += freq
            else:
                stats.append([dkey, freq])

            if len(stats) > hsize:
                break
        # end for s

        if len(stats) <= hsize:
            return stats
        else:
            return stats[0:hsize]

    def _destroyAllApps(self):
        """Destroys the instantiated NLP apps."""

        # Also dump the latest statistics
        # that this object has.
        self._writeStatsFile()

        for app in self._apps:
            print("{0}.{1}[{2}]: destroying NLP app '{3}'".
                  format(
                      Path(inspect.stack()[0].filename).stem,
                      inspect.stack()[0].function,
                      inspect.stack()[0].lineno,
                      app.getAlgoName()
                  ), file=sys.stderr, flush=True)
            app.destroyApp()

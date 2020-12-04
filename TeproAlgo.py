# Author: Radu Ion (radu@racai.ro)
# Developed for the TEPROLIN project
# (C) ICIA 2018-2020

import sys
import inspect
from pathlib import Path


class TeproOp(object):
    """This class represents a TEPROLIN operation, e.g.
    POS tagging or dependency parsing. It can be carried
    out by a number of algorithms and it has a number of
    prerequisites so that it can be performed."""
    def __init__(self, opname: str) -> None:
        self._opName = opname
        self._opNeeds = []
        self._opDoers = []
        self._opAlgo = None

    def addDependency(self, teproop) -> None:
        """Adds an operation that has to be performed
        so that this one can be applied; teproop is of type of this class."""
        self._opNeeds.append(teproop)

    def getDependencies(self) -> list:
        return self._opNeeds

    def addAlgorithm(self, algoname: str) -> None:
        """Adds an NLP application that implements this operation."""
        self._opDoers.append(algoname)

    def setDefaultAlgorithm(self, algoname: str) -> None:
        """Sets the default NLP application to run to get this
        operation done."""
        self._opAlgo = algoname

    def getAlgorithms(self) -> list:
        return self._opDoers

    def getDefaultAlgorithm(self) -> str:
        if self._opAlgo:
            return self._opAlgo
        elif self._opDoers and len(self._opDoers) == 1:
            self._opAlgo = self._opDoers[0]
            return self._opAlgo
        else:
            raise RuntimeError("No default algorithm is set for operation '{0}'!".format(self._opName))
    
    def __str__(self) -> str:
        return self._opName

    def __eq__(self, o: object) -> bool:
        return isinstance(o, TeproOp) and self._opName == o._opName


class TeproAlgo(object):
    """This class will hold the list of available
    TEPROLIN NLP algorithms (or applications/apps).
    Add new ones here!"""

    # Does space and dash normalization, Romanian diacritic
    # normalization (i.e. using ș/ț instead of ş/ţ)
    algoTNorm = "tnorm-icia"

    # Does sentence splitting, tokenization, POS tagging,
    # lemmatization and chunking.
    algoTTL = "ttl-icia"

    # Does sentence splitting, tokenization, POS tagging,
    # lemmatization and dependency parsing.
    algoCube = "nlp-cube-adobe"

    # Does sentence splitting, tokenization, POS tagging,
    # lemmatization and dependency parsing.
    algoUDPipe = "udpipe-ufal"

    # Does Romanian diacritic restoration.
    algoDiac = "diac-restore-icia"

    # Does word hyphenation, accent detection,
    # and phonetic transcription.
    algoTTS = "tts-utcluj"

    # Expands numerals
    # acronyms and abbreviations.
    algoExpn = "expander-utcluj"

    # Provides Named Entity Recognition
    algoNER = "ner-icia"

    # Provides biomedical Named Entity Recognition
    algoBNER = "bioner-icia"

    # Maps operation names to TeproOp objects
    opName2Obj = {}

    @staticmethod
    def getTextNormOperName() -> str:
        return "text-normalization"

    @staticmethod
    def getDiacRestorationOperName() -> str:
        return "diacritics-restoration"

    @staticmethod
    def getHyphenationOperName() -> str:
        return "word-hyphenation"

    @staticmethod
    def getStressIdentificationOperName() -> str:
        return "word-stress-identification"

    @staticmethod
    def getPhoneticTranscriptionOperName() -> str:
        return "word-phonetic-transcription"

    @staticmethod
    def getNumeralRewritingOperName() -> str:
        return "numeral-rewriting"

    @staticmethod
    def getAbbreviationRewritingOperName() -> str:
        return "abbreviation-rewriting"

    @staticmethod
    def getSentenceSplittingOperName() -> str:
        return "sentence-splitting"

    @staticmethod
    def getTokenizationOperName() -> str:
        return "tokenization"

    @staticmethod
    def getPOSTaggingOperName() -> str:
        return "pos-tagging"

    @staticmethod
    def getLemmatizationOperName() -> str:
        return "lemmatization"

    @staticmethod
    def getNamedEntityRecognitionOperName() -> str:
        return "named-entity-recognition"

    @staticmethod
    def getBiomedicalNamedEntityRecognitionOperName() -> str:
        return "biomedical-named-entity-recognition"

    @staticmethod
    def getChunkingOperName() -> str:
        return "chunking"

    @staticmethod
    def getDependencyParsingOperName() -> str:
        return "dependency-parsing"

    @staticmethod
    def getAvailableOperations() -> list:
        """Will return the ordered list of available operations.
        If op i is requested, usually all ops 0:i-1 have to be performed as well,
        but not necessarily."""

        return [
            TeproAlgo.getTextNormOperName(),
            TeproAlgo.getDiacRestorationOperName(),
            TeproAlgo.getSentenceSplittingOperName(),
            TeproAlgo.getTokenizationOperName(),
            TeproAlgo.getHyphenationOperName(),
            TeproAlgo.getStressIdentificationOperName(),
            TeproAlgo.getPhoneticTranscriptionOperName(),
            TeproAlgo.getAbbreviationRewritingOperName(),
            TeproAlgo.getNumeralRewritingOperName(),
            TeproAlgo.getPOSTaggingOperName(),
            TeproAlgo.getLemmatizationOperName(),
            TeproAlgo.getNamedEntityRecognitionOperName(),
            TeproAlgo.getChunkingOperName(),
            TeproAlgo.getDependencyParsingOperName(),
            TeproAlgo.getBiomedicalNamedEntityRecognitionOperName()
        ]

    @staticmethod
    def getAvailableAlgorithms() -> list:
        """Will return a list of recognized NLP apps."""

        return [
            TeproAlgo.algoCube,
            TeproAlgo.algoUDPipe,
            TeproAlgo.algoDiac,
            TeproAlgo.algoTNorm,
            TeproAlgo.algoTTL,
            TeproAlgo.algoTTS,
            TeproAlgo.algoExpn,
            TeproAlgo.algoNER,
            TeproAlgo.algoBNER
        ]

    # Do not forget to update this method with new requirements!
    @staticmethod
    def _getAlgorithmRequirements() -> dict:
        """Will return a dictionary with keys from the return
        list of getAvailableAlgorithms() and values from the same
        list, if some algorithm REQUIRES other(s) to be run first."""
        requirements = {}
        requirements[TeproAlgo.algoNER] = [TeproAlgo.algoTTL]

        return requirements

    @staticmethod
    def getAlgorithmsForOper(oper) -> list:
        if oper in TeproAlgo.opName2Obj:
            return TeproAlgo.opName2Obj[oper].getAlgorithms()
        else:
            return []

    @staticmethod
    def getOperationsForAlgo(algo) -> list:
        cando = []

        if algo in TeproAlgo.getAvailableAlgorithms():
            for op in TeproAlgo.getAvailableOperations():
                if TeproAlgo.canPerform(algo, op):
                    cando.append(op)

            return cando
        else:
            raise RuntimeError("NLP app '" + algo +
                               "' is not recognized. See class TeproAlgo.")

    @staticmethod
    def canPerform(algo: str, oper: str) -> bool:
        return oper in TeproAlgo.opName2Obj and algo in TeproAlgo.opName2Obj[oper].getAlgorithms()

    @staticmethod
    def getDefaultAlgoForOper(oper) -> str:
        if oper in TeproAlgo.opName2Obj:
            return TeproAlgo.opName2Obj[oper].getDefaultAlgorithm()
        else:
            raise RuntimeError("Operation '" + oper +
                               "' is not recognized. See class TeproAlgo.")

    @staticmethod
    def resolveDependencies(operations: list) -> list:
        """Will fill in the transitive closure for list operations,
        given known operations dependencies. The result is placed
        inside the argument list."""
        
        expanded = []

        for op in operations:
            expanded.append(op)
            
            for np in TeproAlgo.opName2Obj[op].getDependencies():
                npn = str(np)

                if npn not in operations:
                    expanded.append(npn)
            # end for np
        # end for op

        if len(operations) == len(expanded):
            # Sort operations as per order specified by getAvailableOperations()
            allOperations = TeproAlgo.getAvailableOperations()
            operations.sort(key=lambda x: allOperations.index(x))
            return operations
        else:
            return TeproAlgo.resolveDependencies(expanded)

    @staticmethod
    def reconfigureWithStrictRequirements(conf: dict) -> None:
        """Will check strict algorithm dependency requirements,
        and will set them appropriately."""
        requirements = TeproAlgo._getAlgorithmRequirements()

        for op in conf:
            algo = conf[op]

            if algo in requirements:
                ralgo = requirements[algo]

                if TeproAlgo.canPerform(ralgo, op):
                    conf[op] = ralgo
                    print(("{0}.{1}[{2}]: " +
                           "configuration exception triggered by operation '{3}' with algorithm '{4}': " +
                           "reconfiguring operation '{5}' with algorithm '{6}'").
                          format(
                        Path(inspect.stack()[0].filename).stem,
                        inspect.stack()[0].function,
                        inspect.stack()[0].lineno,
                        op,
                        algo,
                        op,
                        ralgo
                    ), file=sys.stderr, flush=True)
                # end if can perform
            # end if algo
        # end for all ops
  
    @staticmethod
    def _assignAlgorithmsToOperations():
        """Constructs the operation dependency graph."""
        
        operations = []
        tn = TeproOp(TeproAlgo.getTextNormOperName())
        tn.addAlgorithm(TeproAlgo.algoTNorm)
        operations.append(tn)

        dr = TeproOp(TeproAlgo.getDiacRestorationOperName())
        dr.addAlgorithm(TeproAlgo.algoDiac)
        dr.addDependency(tn)
        operations.append(dr)

        ss = TeproOp(TeproAlgo.getSentenceSplittingOperName())
        ss.addAlgorithm(TeproAlgo.algoUDPipe)
        ss.addAlgorithm(TeproAlgo.algoTTL)
        ss.addAlgorithm(TeproAlgo.algoCube)
        ss.setDefaultAlgorithm(TeproAlgo.algoUDPipe)
        ss.addDependency(dr)
        operations.append(ss)

        tk = TeproOp(TeproAlgo.getTokenizationOperName())
        tk.addAlgorithm(TeproAlgo.algoUDPipe)
        tk.addAlgorithm(TeproAlgo.algoTTL)
        tk.addAlgorithm(TeproAlgo.algoCube)
        tk.setDefaultAlgorithm(TeproAlgo.algoUDPipe)
        tk.addDependency(ss)
        operations.append(tk)

        pt = TeproOp(TeproAlgo.getPOSTaggingOperName())
        pt.addAlgorithm(TeproAlgo.algoUDPipe)
        pt.addAlgorithm(TeproAlgo.algoTTL)
        pt.addAlgorithm(TeproAlgo.algoCube)
        pt.setDefaultAlgorithm(TeproAlgo.algoUDPipe)
        pt.addDependency(tk)
        operations.append(pt)

        lm = TeproOp(TeproAlgo.getLemmatizationOperName())
        lm.addAlgorithm(TeproAlgo.algoUDPipe)
        lm.addAlgorithm(TeproAlgo.algoTTL)
        lm.addAlgorithm(TeproAlgo.algoCube)
        lm.setDefaultAlgorithm(TeproAlgo.algoUDPipe)
        lm.addDependency(pt)
        operations.append(lm)

        ck = TeproOp(TeproAlgo.getChunkingOperName())
        ck.addAlgorithm(TeproAlgo.algoTTL)
        ck.addDependency(pt)
        operations.append(ck)

        dp = TeproOp(TeproAlgo.getDependencyParsingOperName())
        dp.addAlgorithm(TeproAlgo.algoUDPipe)
        dp.addAlgorithm(TeproAlgo.algoCube)
        dp.setDefaultAlgorithm(TeproAlgo.algoUDPipe)
        dp.addDependency(lm)
        operations.append(dp)

        hy = TeproOp(TeproAlgo.getHyphenationOperName())
        hy.addAlgorithm(TeproAlgo.algoTTS)
        hy.addDependency(tk)
        operations.append(hy)

        ac = TeproOp(TeproAlgo.getStressIdentificationOperName())
        ac.addAlgorithm(TeproAlgo.algoTTS)
        ac.addDependency(tk)
        operations.append(ac)

        ph = TeproOp(TeproAlgo.getPhoneticTranscriptionOperName())
        ph.addAlgorithm(TeproAlgo.algoTTS)
        ph.addDependency(tk)
        operations.append(ph)

        nr = TeproOp(TeproAlgo.getNumeralRewritingOperName())
        nr.addAlgorithm(TeproAlgo.algoExpn)
        nr.addDependency(tk)
        operations.append(nr)

        ar = TeproOp(TeproAlgo.getAbbreviationRewritingOperName())
        ar.addAlgorithm(TeproAlgo.algoExpn)
        ar.addDependency(tk)
        operations.append(ar)

        er = TeproOp(TeproAlgo.getNamedEntityRecognitionOperName())
        er.addAlgorithm(TeproAlgo.algoNER)
        er.addDependency(lm)
        operations.append(er)

        ber = TeproOp(TeproAlgo.getBiomedicalNamedEntityRecognitionOperName())
        ber.addAlgorithm(TeproAlgo.algoBNER)
        ber.addDependency(dp)
        operations.append(ber)

        for op in operations:
            TeproAlgo.opName2Obj[str(op)] = op

        # Some sanity checks
        # 1. All operations are in the list, no invented names.
        for op in TeproAlgo.getAvailableOperations():
            assert op in TeproAlgo.opName2Obj

        # 2. All of them are covered by definitions
        assert len(TeproAlgo.getAvailableOperations()) == len(TeproAlgo.opName2Obj)

        # 3. All operations have a default algorithm
        for op in operations:
            op.getDefaultAlgorithm()

TeproAlgo._assignAlgorithmsToOperations()

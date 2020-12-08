import sys
from TeproAlgo import TeproAlgo


class TeproDTO(object):
    """This class will encapsulate all data that is
    sent back and forth among NLP apps that belong
    to the TEPROLIN platform."""

    def __init__(self, text: str, conf: dict):
        # The original text to be preprocessed
        self._text = text
        # The sentence splitter will store each
        # sentence in this list, as a str
        self._sentences = []
        # This is a list of lists of TeproTok(s) with
        # all available information
        self._tokenized = []
        # The set of all performed operations on
        # this DTO object
        self._performedOps = set()
        # This is the configuration dict
        # that comes from Teprolin
        self._opsConf = conf
        # Number of processed tokens in
        # this DTO
        self._proctoks = 0

    def getProcessedTokens(self):
        return self._proctoks

    def getConfiguredAlgoForOper(self, oper: str):
        if oper in self._opsConf:
            return self._opsConf[oper]

        return None

    def addPerformedOp(self, op: str):
        if op in TeproAlgo.getAvailableOperations():
            self._performedOps.add(op)
        else:
            raise RuntimeError("Operation '" + op +
                               "' is not a valid TeproAlgo operation!")

    def isOpPerformed(self, op: str) -> bool:
        if op in TeproAlgo.getAvailableOperations():
            return op in self._performedOps
        else:
            raise RuntimeError("Operation '" + op +
                               "' is not a valid TeproAlgo operation!")

    def setText(self, text: str):
        self._text = text

    def getText(self) -> str:
        return self._text

    def getNumberOfSentences(self) -> int:
        return len(self._sentences)

    def getSentenceString(self, i: int):
        """Get the i-th sentence."""

        if i >= 0 and i < len(self._sentences):
            return self._sentences[i]

        return None

    def getSentenceTokens(self, i: int):
        """Get the i-th sentence as a list of TeproTok(s)."""

        if i >= 0 and i < len(self._tokenized):
            return self._tokenized[i]

        return None

    def addSentenceTokens(self, tokens: list):
        """Adds a new list of TeproTok(s) to the internal
        list of tokenized sentences."""

        self._tokenized.append(tokens)
        self._proctoks += len(tokens)

    def addSentenceString(self, sentence: str):
        """Adds a str sentence to the list of internal
        list of sentences."""

        self._sentences.append(sentence)

    def dumpConllX(self, outfile=sys.stdout):
        """Prints the CoNLL-X format in outfile,
        for the current DTO."""

        for ts in self._tokenized:
            for tt in ts:
                print(tt.getConllXRecord(), file=outfile)

            print(file=outfile, flush=True)

    def jsonDict(self):
        """Returns the dict representation of this DTO
        for JSON encoding."""

        return {
            'text': self._text,
            'sentences': self._sentences,
            'tokenized': self._tokenized
        }

    def alignSentences(self, fromSent: list, sid: int):
        if sid < len(self._tokenized):
            toSent = self._tokenized[sid]
            # Indexes into fromSent
            i = 0
            # Indexes into toSent
            j = 0
            alignment = []

            while i < len(fromSent) and j < len(toSent):
                fromTok = fromSent[i]
                toTok = toSent[j]

                if fromTok == toTok:
                    # Sentences are in sync
                    alignment.append((i, j))
                    # And advance one position
                    i += 1
                    j += 1
                else:
                    oi = i
                    oj = j
                    aFound = False

                    for i in range(oi, oi + 10):
                        if i >= len(fromSent):
                            break

                        fromTok = fromSent[i]

                        for j in range(oj, oj + 10):
                            if j >= len(toSent):
                                break

                            toTok = toSent[j]

                            if fromTok == toTok:
                                # Add all sources indexes which do
                                # not match with all target indexes which
                                # do not match.
                                for ii in range(oi, i):
                                    for jj in range(oj, j):
                                        alignment.append((ii, jj))

                                # Sentences are in sync
                                alignment.append((i, j))
                                # And advance one position
                                i += 1
                                j += 1
                                aFound = True
                                break
                        # end for y
                        if aFound:
                            break
                    # end for x
                    if not aFound:
                        return None
                # end else (alignment out of sync)
            # end while
            return alignment
        else:
            return None

    def copyTokenAnnotation(self, fromSent: list, sid: int, align: list, oper: str):
        """Copy the annotation corresponding to oper from fromSent into
        the sentence with sid in self._tokenized.
        Use the align list to map from fromSent into sentence with sid in self._tokenized."""

        if align is None:
            return

        if sid < len(self._tokenized):
            toSent = self._tokenized[sid]

            for (i, j) in align:
                fromTok = fromSent[i]
                toTok = toSent[j]
                toTok.copyFrom(fromTok, align, oper)

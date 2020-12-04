from TeproConfig import DIACMODELFILE, DIACWFREQFILE
import unicodedata as uc
import math
import os
import sys
import re
import inspect
from pathlib import Path
from copy import deepcopy
from TeproApi import TeproApi
from TeproAlgo import TeproAlgo


class Token(object):
    """Token class used by the DiacRestore class."""

    romanianWordChars = set(
        "aăâbcdefghiîjklmnopqrsșştțţuvwxyz" +
        "aăâbcdefghiîjklmnopqrsșştțţuvwxyz".upper() +
        "0123456789" +
        "_-")

    def __init__(self):
        self._score = float('-inf')
        self._maxFrom = -1
        self._token = None
        self._isRoWord = False
        self._spaceAfter = ""

# Author: Radu ION, (C) ICIA 2018
# Part of the TEPROLIN platform.
class DiacRestore(TeproApi):
    """This is a Python 3 port of Tiberiu Boroș's DiacRestore Java app,
    used in the Corola pipeline. No references so far."""

    # If percent of invalid words is at least this,
    # perform diacritic restoration.
    # An 'invalid word' is a word that lacks required
    # diacritics, such as 'masina' -> 'mașina' or 'mașină'.
    diacInvalidPercent = 0.03
    intPattern = re.compile("^[0-9]+$")

    def __init__(self):
        super().__init__()
        self._algoName = TeproAlgo.algoDiac
        self._wrd2List = {}
        self._wrdFreq = {}
        self._ngrams = {}
        self._totalUni = 0

    @staticmethod
    def matchCase(lower: str, correct: str) -> str:
        """Will copy the case of correct to lower."""

        sb = []
        upper = lower.upper()
        correctUpper = correct.upper()

        for i in range(len(correct)):
            if lower[i] == correct[i]:
                sb.append(lower[i])
                continue

            if correctUpper[i] == correct[i]:
                sb.append(upper[i])
                continue

            sb.append(lower[i])

        return "".join(sb)

    @staticmethod
    def getWords(text: str) -> list:
        """Will tokenize the input text."""

        words = []
        cwrd = ""
        cspc = ""

        for i in range(len(text)):
            c = text[i]
            ccat = uc.category(c)

            if c in Token.romanianWordChars:
                if cspc and words:
                    words[-1]._spaceAfter = cspc
                    cspc = ""

                cwrd += c
            elif ccat == 'Zs' or ccat == 'Cc':
                if cwrd:
                    tok = Token()
                    tok._token = cwrd
                    tok._isRoWord = True
                    words.append(tok)
                    cwrd = ""

                cspc += c
            else:
                if cwrd:
                    tok = Token()
                    tok._token = cwrd
                    tok._isRoWord = True
                    words.append(tok)
                    cwrd = ""

                if cspc and words:
                    words[-1]._spaceAfter = cspc
                    cspc = ""

                tok = Token()
                tok._token = c
                words.append(tok)

        if cspc and words:
            words[-1]._spaceAfter = cspc
        elif cwrd:
            tok = Token()
            tok._token = cwrd
            tok._isRoWord = True
            words.append(tok)

        return words

    @staticmethod
    def lowerAndRemoveDiacs(text: str) -> str:
        # Converts the argument to lower-case
        stripped = text.lower()
        # Removes all diacritics
        stripped = stripped.replace("\u0103", "a")
        stripped = stripped.replace("\u00e2", "a")
        stripped = stripped.replace("\u0219", "s")
        stripped = stripped.replace("\u021b", "t")
        stripped = stripped.replace("\u00ee", "i")

        return stripped

    def _appendWF(self, wordForm: str):
        """Adds words to the internal data structures."""

        # Removes all diacritics
        stripped = DiacRestore.lowerAndRemoveDiacs(wordForm)

        if stripped not in self._wrd2List:
            self._wrd2List[stripped] = []

        lowerWordForm = wordForm.lower()

        if lowerWordForm not in self._wrd2List[stripped]:
            self._wrd2List[stripped].append(lowerWordForm)

    def _isRestoreRequired(self, tokens: list) -> bool:
        """Decides if the current text has enough invalid
        words such that a recovery is in order."""

        # Invalid word count
        iwc = 0
        # Words with possible diacritics count
        dwc = 0

        for tok in tokens:
            if tok._isRoWord:
                word = tok._token.lower()

                if word in self._wrd2List:
                    dwc += 1.0

                    if word not in self._wrd2List[word]:
                        iwc += 1.0
                    elif len(self._wrd2List[word]) >= 2:
                        # If word is e.g. 'si' but the more
                        # frequent form is 'și', we add this
                        # to the invalid count.
                        # Same with 'in' vs. 'în'.
                        w1 = self._wrd2List[word][0]
                        w2 = self._wrd2List[word][1]

                        if w1 in self._wrdFreq and w2 in self._wrdFreq:
                            w1f = self._wrdFreq[w1]
                            w2f = self._wrdFreq[w2]
                            iwc += (1.0 - float(w2f) / float(w1f))
        # end for tok

        if dwc > 0:
            iwPerc = float(iwc) / float(dwc)

            if iwPerc >= DiacRestore.diacInvalidPercent:
                return True

        return False

    def _restore(self, text: str) -> str:
        """This is the main method of the class. Give it a text
        and get back the text with diacritics."""

        tokens = DiacRestore.getWords(text)

        if not self._isRestoreRequired(tokens):
            return text

        dtokens = self._viterbiDecoder(tokens)
        # tokens and dtokens have the same length!
        sb = []

        for i in range(len(dtokens)):
            if tokens[i]._isRoWord:
                sb.append(DiacRestore.matchCase(
                    dtokens[i]._token, tokens[i]._token))
            else:
                sb.append(tokens[i]._token)

            sb.append(tokens[i]._spaceAfter)

        return "".join(sb)

    def _viterbiDecoder(self, tokens: list) -> list:
        if not tokens:
            return []

        a = [None for i in range(len(tokens))]

        for i in range(len(tokens)):
            a[i] = self._getViterbiTokens(tokens[i])

            if i != 0:
                continue

            for j in range(len(a[i])):
                a[i][j]._score = self._lm("_", "_", a[i][j]._token)

        for index in range(1, len(tokens)):
            for cur in range(len(a[index])):
                bestScore = float('-inf')

                for prev in range(len(a[index - 1])):
                    pp = "_"
                    p = a[index - 1][prev]._token
                    c = a[index][cur]._token

                    if index > 1:
                        pp = a[index - 2][a[index - 1][prev]._maxFrom]._token

                    s = self._lm(pp, p, c) + a[index - 1][prev]._score

                    if s <= bestScore:
                        continue

                    bestScore = s
                    a[index][cur]._maxFrom = prev

                a[index][cur]._score = bestScore

        pos = len(a) - 1
        maxFrom = 0

        for i2 in range(len(a[pos])):
            if a[pos][maxFrom]._score >= a[pos][i2]._score:
                continue

            maxFrom = i2

        decoded = [None for i in range(len(a))]

        while pos >= 0:
            decoded[pos] = a[pos][maxFrom]
            maxFrom = a[pos][maxFrom]._maxFrom
            pos -= 1

        return decoded

    def _getViterbiTokens(self, t: Token) -> list:
        """Retrieves the alternatives for Token t."""

        stripped = DiacRestore.lowerAndRemoveDiacs(t._token)

        if stripped not in self._wrd2List:
            tok = deepcopy(t)

            return [tok]

        sList = self._wrd2List[stripped]
        rez = [None for i in range(len(sList))]

        for i in range(len(sList)):
            rez[i] = Token()
            rez[i]._token = sList[i]
            rez[i]._isRoWord = True

        return rez

    def _lm(self, pp: str, p: str, c: str) -> float:
        """Computes the log LM probability of P(c|pp, p). That is, the
        trigram probability of word 'c', given the context 'pp p'."""

        pUni = 0.0
        pTri = 0.0
        pBi = 0.0
        prob = 0.0
        uni = c
        bi = p + " " + c
        tri = pp + " " + p + " " + c
        cUni = 0
        cBi = 0
        cTri = 0

        if uni in self._ngrams:
            cUni = self._ngrams[uni]

        if bi in self._ngrams:
            cBi = self._ngrams[bi]

        if tri in self._ngrams:
            cTri = self._ngrams[tri]

        pUni = float(cUni) / (float(self._totalUni) + 1.0)
        pBi = float(cBi) / (float(cUni) + 1.0)
        pTri = float(cTri) / (float(cBi) + 1.0)
        # Radu: these weights have to be trained,
        # see the TnT POS tagger approach.
        prob = pUni * 0.1 + pBi * 0.3 + pTri * 0.6

        if math.fabs(prob) < 1e-10:
            prob = 1.0 / float(self._totalUni)

        return math.log(prob)

    def _runApp(self, dto, opNotDone):
        dtext = self._restore(dto.getText())
        dto.setText(dtext)

        return dto

    def _readWordFreqFile(self):
        """Reads in the word frequency file with which we
        decide which word form is more likely."""

        with open(DIACWFREQFILE, mode='r', encoding='utf-8') as f:
            for line in f:
                parts = line.strip().split()
                word = parts[0].lower()
                freq = int(parts[1])

                if len(parts) == 2:
                    if word not in self._wrdFreq:
                        self._wrdFreq[word] = freq
                    else:
                        self._wrdFreq[word] += freq
                # end if
            # end for line
        # end with

    def loadResources(self):
        f = open(DIACMODELFILE, mode="r", encoding="utf-8")
        line = f.readline().strip()
        count = int(line)

        for i in range(count):
            if i > 0 and i % 100000 == 0:
                print("{0}.{1}[{2}]: loading lexicon, at line {3}/{4}".
                      format(
                          Path(inspect.stack()[0].filename).stem,
                          inspect.stack()[0].function,
                          inspect.stack()[0].lineno,
                          i,
                          count
                      ), file=sys.stderr, flush=True)

            line = f.readline().strip()
            self._appendWF(line)

        line = f.readline().strip()
        count = int(line)

        for i in range(count):
            if i > 0 and i % 1000000 == 0:
                print("{0}.{1}[{2}]: loading ngrams, at line {3}/{4}".
                      format(
                          Path(inspect.stack()[0].filename).stem,
                          inspect.stack()[0].function,
                          inspect.stack()[0].lineno,
                          i,
                          count
                      ), file=sys.stderr, flush=True)

            line = f.readline().strip()

            if not line:
                continue

            # Malformed model created by Java.
            # Test 1: line does not begin with space
            if uc.category(line[0]) == 'Zs':
                print("{0}.{1}[{2}]: space not allowed at line start, at line {3}/{4}".
                      format(
                          Path(inspect.stack()[0].filename).stem,
                          inspect.stack()[0].function,
                          inspect.stack()[0].lineno,
                          i,
                          count
                      ), file=sys.stderr, flush=True)
                continue

            pp = line.split('\t')

            # Test 2: there are two parts, separated by TAB
            if len(pp) != 2:
                print("{0}.{1}[{2}]: no TAB in line, at line {3}/{4}".
                      format(
                          Path(inspect.stack()[0].filename).stem,
                          inspect.stack()[0].function,
                          inspect.stack()[0].lineno,
                          i,
                          count
                      ), file=sys.stderr, flush=True)
                continue

            ngram = pp[0]

            # Test 3: pp[1] should be an integer
            if not DiacRestore.intPattern.match(pp[1]):
                print("{0}.{1}[{2}]: count not valid, at line {3}/{4}".
                      format(
                          Path(inspect.stack()[0].filename).stem,
                          inspect.stack()[0].function,
                          inspect.stack()[0].lineno,
                          i,
                          count
                      ), file=sys.stderr, flush=True)
                continue

            ngramCount = int(pp[1])

            self._ngrams[ngram] = ngramCount

            ngramlen = len(ngram.split(' '))

            if ngramlen != 1:
                continue

            self._totalUni += ngramCount
            self._appendWF(ngram)

        f.close()

        # Reads word frequencies
        print("{0}.{1}[{2}]: reading word frequency file".
              format(
                  Path(inspect.stack()[0].filename).stem,
                  inspect.stack()[0].function,
                  inspect.stack()[0].lineno
              ), file=sys.stderr, flush=True)

        self._readWordFreqFile()

        print("{0}.{1}[{2}]: sorting variants by frequency".
              format(
                  Path(inspect.stack()[0].filename).stem,
                  inspect.stack()[0].function,
                  inspect.stack()[0].lineno
              ), file=sys.stderr, flush=True)

        # Sort entries in self._wrd2List by frequency
        for wnd in self._wrd2List:
            self._wrd2List[wnd].sort(
                key=lambda x: self._wrdFreq[x] if x in self._wrdFreq else 0,
                reverse=True
            )

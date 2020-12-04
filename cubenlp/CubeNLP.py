import sys
from pathlib import Path
import inspect
from TeproConfig import CTAG2MSDMAPFILE, TBLWORDFORMFILE
from TeproApi import TeproApi
from TeproAlgo import TeproAlgo
from TeproTok import TeproTok
from cube.api import Cube

# pip3 install nlpcube
# See here: https://github.com/adobe/NLP-Cube
# To download the models, do the following:
#
# set PYTHON_HOME="D:\Program Files (x86)\Microsoft Visual Studio\Shared\Python36_64" (or whatever your PYTHON home is)
# python "%PYTHON_HOME%\Lib\site-packages\scripts\download_model.py" --language ro
# Also make sure you have the corpus\trained_models\ro created in the PyTEPRO folder!
#
# It seems that the models are automatically downloaded from the Internet.
# The models are saved in %USERPROFILE%\.nlpcube


class CubeNLP(TeproApi):
    """By Tibi Boroș & co., does sentence splitting, tokenization,
    POS tagging, lemmatization and dependency parsing for Romanian."""

    def __init__(self):
        super().__init__()
        self._algoName = TeproAlgo.algoCube

    @staticmethod
    def sgml2unicode(word: str) -> str:
        word = word.replace("&abreve;", "ă")
        word = word.replace("&Abreve;", "Ă")
        word = word.replace("&acirc;", "â")
        word = word.replace("&Acirc;", "Â")
        word = word.replace("&icirc;", "î")
        word = word.replace("&Icirc;", "Î")
        word = word.replace("&scedil;", "ș")
        word = word.replace("&Scedil;", "Ș")
        word = word.replace("&tcedil;", "ț")
        word = word.replace("&Tcedil;", "Ț")

        return word

    @staticmethod
    def _readMSDMappings():
        m2c = {}

        with open(CTAG2MSDMAPFILE, mode="r") as f:
            for line in f:
                line = line.strip()
                parts = line.split()

                if len(parts) == 2:
                    msd = parts[0]
                    ctg = parts[1]
                    m2c[msd] = ctg
                # end if
            # end for line
        # end open file
        return m2c

    @staticmethod
    def _readTblWordForm():
        tbl = {}
        counter = 0

        with open(TBLWORDFORMFILE, mode="r", encoding="utf-8") as f:
            for line in f:
                counter += 1

                if counter > 0 and counter % 100000 == 0:
                    print("{0}.{1}[{2}]: loading tbl.wordform.ro, at line {3}".
                          format(
                              Path(inspect.stack()[0].filename).stem,
                              inspect.stack()[0].function,
                              inspect.stack()[0].lineno,
                              counter
                          ), file=sys.stderr, flush=True)

                line = line.strip()

                if line.startswith("#"):
                    continue

                parts = line.split()

                if len(parts) == 3:
                    word = CubeNLP.sgml2unicode(parts[0])
                    lemma = CubeNLP.sgml2unicode(parts[1])

                    if lemma == '=':
                        lemma = word

                    msd = parts[2]

                    if word not in tbl:
                        tbl[word] = {}

                    if msd not in tbl[word]:
                        tbl[word][msd] = []

                    tbl[word][msd].append(lemma)
                # end if parts has 3 elems
            # end for line in f
        # end while open file
        return tbl

    def createApp(self):
        self._cubeInst = Cube(verbose=True)

    def loadResources(self):
        self._cubeInst.load(
            'ro', tokenization=True,
            compound_word_expanding=False,
            tagging=True,
            lemmatization=True,
            parsing=True
        )
        self._tblwordform = CubeNLP._readTblWordForm()
        self._msd2ctag = CubeNLP._readMSDMappings()

    def _runApp(self, dto, opNotDone):
        text = dto.getText()
        sentences = self._cubeInst(text)
        sid = 0

        for sent in sentences:
            # Teprolin tokenized sentence
            ttsent = []
            # Teprolin string sentence
            tssent = ""

            for tok in sent:
                tt = TeproTok()
                tt.setId(tok.index)
                tt.setWordForm(tok.word)
                lowerWord = tok.word.lower()
                tt.setMSD(tok.xpos)

                # Assigning the mapped CTAG to the disambiguated MSD
                if tok.xpos in self._msd2ctag:
                    tt.setCTAG(self._msd2ctag[tok.xpos])
                else:
                    tt.setCTAG(tok.xpos)

                lemmaIsSet = False

                # Doing lexicon lemmatization, if possible.
                if tok.word in self._tblwordform:
                    if tok.xpos in self._tblwordform[tok.word] and \
                            len(self._tblwordform[tok.word][tok.xpos]) == 1:
                        # TODO: if lemma is ambiguous, e.g. 'copii' can be 'copil' or 'copie'
                        tt.setLemma(self._tblwordform[tok.word][tok.xpos][0])
                        lemmaIsSet = True
                elif lowerWord in self._tblwordform and \
                        tok.xpos in self._tblwordform[lowerWord] and \
                        len(self._tblwordform[lowerWord][tok.xpos]) == 1:
                    tt.setLemma(self._tblwordform[lowerWord][tok.xpos][0])
                    lemmaIsSet = True

                if not lemmaIsSet:
                    tt.setLemma(tok.lemma)

                tt.setHead(tok.head)
                tt.setDepRel(tok.label)

                tssent += tok.word

                if tok.space_after != "SpaceAfter=No":
                    tssent += " "

                ttsent.append(tt)
            # end ttsent/tssent formation

            if not dto.isOpPerformed(TeproAlgo.getSentenceSplittingOperName()):
                dto.addSentenceString(tssent)
                dto.addSentenceTokens(ttsent)
            else:
                # Check and update annotations that only NLPCube
                # can produce or that are requested specifically from it.
                alignment = dto.alignSentences(ttsent, sid)

                for op in opNotDone:
                    dto.copyTokenAnnotation(ttsent, sid, alignment, op)

            sid += 1

        return dto

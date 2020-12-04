from TeproConfig import BIONERMODELNAME, BIONERWORDEMBEDFILE
from TeproApi import TeproApi
from TeproAlgo import TeproAlgo
# It also apparently works with the NLP-Cube installation.
# Just remove the bioner. prefix from the imports below.
from bioner.io_utils.encodings import Encodings
from bioner.io_utils.config import TaggerConfig
from bioner.io_utils.embeddings import WordEmbeddings
from bioner.io_utils.conll import ConllEntry
from bioner.generic_networks.taggers import BDRNNTagger

# Author: Radu ION, (C) ICIA 2018-2019
# To be included in the TEPROLIN platform.
class BioNEROps(TeproApi):
    """This is an adaptation of the Bio NER algorithm provided
    by Maria Mitrofan, based on an older version of the NLP-Cube app."""

    def __init__(self):
        super().__init__()
        self._algoName = TeproAlgo.algoBNER

    def createApp(self):
        self._encodings = Encodings()
        self._encodings.load(BIONERMODELNAME + ".encodings")
        self._config = TaggerConfig()
        self._embeddings = WordEmbeddings()
        # Load all the embeddings as a cache word to file offset
        self._embeddings.read_from_file(BIONERWORDEMBEDFILE, None)
        self._tagger = BDRNNTagger(self._config, self._encodings, self._embeddings)
        self._tagger.load(BIONERMODELNAME + ".bestUPOS")

    def _prepareSentences(self, dto) -> list:
        result = []

        for i in range(dto.getNumberOfSentences()):
            tsent = dto.getSentenceTokens(i)
            csent = []

            for tok in tsent:
                cent = \
                    ConllEntry(
                        tok.getId(), tok.getWordForm(), tok.getLemma(), "_",
                        tok.getMSD(), "_", tok.getHead(), tok.getDepRel(), "_")
                csent.append(cent)
            # end for tok

            result.append(csent)
        # end for i
        return result

    def _runApp(self, dto, opNotDone):
        if not TeproAlgo.getBiomedicalNamedEntityRecognitionOperName() in opNotDone:
            return dto

        sequences = self._prepareSentences(dto)
        i = 0

        for seq in sequences:
            rez = self._tagger.tag(seq)
            tsent = dto.getSentenceTokens(i)

            # These are equal, but just in case...
            if len(rez) == len(tsent):
                for j in range(len(rez)):
                    if tsent[j].getMSD() == rez[j][1]:
                        bnlabel = rez[j][0]

                        if bnlabel != '' and \
                            bnlabel != '_' and bnlabel != '-':
                            tsent[j].setBioNER(bnlabel)
                        # end if bnlabel
                    # end if ==
                # end for j
            # end if len
            i += 1
        # end for
        return dto


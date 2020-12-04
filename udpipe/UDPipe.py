import sys
from pathlib import Path
import inspect
from TeproConfig import UDPIPEMODELFILE
from TeproApi import TeproApi
from TeproAlgo import TeproAlgo
from TeproTok import TeproTok
from ufal.udpipe import Model, ProcessingError, Sentence

# This is part of the TEPROLIN platform.
# (C) ICIA, Radu Ion (radu@racai.ro) 2020


class UDPipe(TeproApi):
    """This is the wrapper of the UDPipe text pre-processor
    compatible with the TEPROLIN platform.
    For more information, please take a look at
    http://ufal.mff.cuni.cz/udpipe"""

    def __init__(self):
        super().__init__()
        self._algoName = TeproAlgo.algoUDPipe
        self._model = None

    def loadResources(self):
        print("{0}.{1}[{2}]: loading UDPipe model from file {3}".
              format(
                  Path(inspect.stack()[0].filename).stem,
                  inspect.stack()[0].function,
                  inspect.stack()[0].lineno,
                  UDPIPEMODELFILE
              ), file=sys.stderr, flush=True)

        self._model = Model.load(UDPIPEMODELFILE)

        if not self._model:
            print("{0}.{1}[{2}]: could not load UDPipe model!".
                  format(
                      Path(inspect.stack()[0].filename).stem,
                      inspect.stack()[0].function,
                      inspect.stack()[0].lineno,
                  ), file=sys.stderr, flush=True)

    def _runApp(self, dto, opNotDone):
        text = dto.getText()

        tokenizer = self._model.newTokenizer(self._model.DEFAULT)
        tokenizer.setText(text)
        error = ProcessingError()
        sentence = Sentence()
        sid = 0

        while tokenizer.nextSentence(sentence, error):
            self._model.tag(sentence, self._model.DEFAULT)
            self._model.parse(sentence, self._model.DEFAULT)
            # Teprolin tokenized sentence
            ttsent = []
            # Teprolin string sentence
            tssent = sentence.getText()

            for w in sentence.words:
                if w.id == 0:
                    continue

                tt = TeproTok()

                tt.setId(w.id)
                tt.setWordForm(w.form)
                tt.setCTAG(w.upostag)
                tt.setMSD(w.xpostag)
                tt.setLemma(w.lemma)
                tt.setHead(w.head)
                tt.setDepRel(w.deprel)

                ttsent.append(tt)
            # end for w

            if not dto.isOpPerformed(TeproAlgo.getSentenceSplittingOperName()):
                dto.addSentenceString(tssent)
                dto.addSentenceTokens(ttsent)
            else:
                # Check and update annotations that only TTL
                # can produce or that are requested specifically from it.
                alignment = dto.alignSentences(ttsent, sid)

                for op in opNotDone:
                    dto.copyTokenAnnotation(ttsent, sid, alignment, op)

            sentence = Sentence()
            sid += 1
        # end all split sentences.

        return dto

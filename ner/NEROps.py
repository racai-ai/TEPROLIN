import sys
import inspect
from pathlib import Path
import requests
from TeproApi import TeproApi
from TeproAlgo import TeproAlgo
from TeproConfig import GENERALNERURL

# Author: Radu ION, (C) ICIA 2018-2020
# Part of the TEPROLIN platform.
class NEROps(TeproApi):
    def __init__(self):
        super().__init__()
        self._algoName = TeproAlgo.algoNER

    def _prepareSentences(self, dto) -> str:
        result = []

        for i in range(dto.getNumberOfSentences()):
            tsent = dto.getSentenceTokens(i)
            result.append("<s>\t<s>\t<s>\t<s>\t<s>")

            for tok in tsent:
                msd = tok.getMSD()
                shortmsd = ""

                if len(msd) >= 2:
                    shortmsd = msd[0:2]
                else:
                    shortmsd = msd

                result.append(
                    tok.getWordForm() + "\t" +
                    tok.getLemma() + "\t" +
                    msd + "\t" +
                    shortmsd + "\t" +
                    tok.getCTAG()
                )
            # end for tok
            result.append("</s>\t</s>\t</s>\t</s>\t</s>")
        # end for i
        return "\n".join(result)

    def _runApp(self, dto, opNotDone):
        if not TeproAlgo.getNamedEntityRecognitionOperName() in opNotDone:
            return dto

        sentences = self._prepareSentences(dto)
        resp = requests.post(GENERALNERURL, data={"tokens": sentences})

        if resp.ok:
            nsentences = resp.text.split("\n")
            i = -1
            csentence = []

            for ntok in nsentences:
                if not ntok:
                    # Skip empty strings.
                    continue

                if ntok.startswith("<s>"):
                    i += 1
                elif ntok.startswith("</s>"):
                    tsentence = dto.getSentenceTokens(i)

                    if len(csentence) == len(tsentence):
                        for j in range(len(tsentence)):
                            if tsentence[j].getWordForm() == csentence[j][0] and \
                                    csentence[j][1] != "O":
                                tsentence[j].setNER(csentence[j][1])

                    csentence = []
                else:
                    parts = ntok.split()
                    csentence.append((parts[0], parts[5]))
            # end for ntok
        else:
            print("{0}.{1}[{2}]: connecting to {3} failed with code {4}".
                  format(
                      Path(inspect.stack()[0].filename).stem,
                      inspect.stack()[0].function,
                      inspect.stack()[0].lineno,
                      GENERALNERURL,
                      resp.status_code
                  ), file=sys.stderr, flush=True)

        return dto

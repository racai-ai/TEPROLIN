import re
import unicodedata as uc
from TeproApi import TeproApi
from TeproAlgo import TeproAlgo

class TextNorm(TeproApi):
    """This class will handle Romanian text normalization:
    - space normalization
    - hyphen normalization
    - old/new diacritics convention"""

    diacNew2Old = {
        "ș": "ş",
        "ț": "ţ",
        "Ș": "Ş",
        "Ț": "Ţ"
    }
    diacOld2New = {
        "ş": "ș",
        "ţ": "ț",
        "Ş": "Ș",
        "Ţ": "Ț"
    }
    # Preserve newlines!
    spacePattern = re.compile("(\\t| )+")

    def __init__(self):
        super().__init__()
        self._algoName = TeproAlgo.algoTNorm
        self._diacTable = TextNorm.diacOld2New

    def setNewToOldConv(self):
        """New method, not in the TeproApi interface."""

        self._diacTable = TextNorm.diacNew2Old

    def _runApp(self, dto, opNotDone):
        text = dto.getText()
        text2 = ""

        # Step 1: diacritic conversion
        for c in text:
            if c in self._diacTable:
                text2 += self._diacTable[c]
            else:
                text2 += c

        # Step 2: remove extra spaces
        text3 = text2.strip()
        text4 = TextNorm.spacePattern.sub(" ", text3)

        # Step 3: normalize the dashes
        text5 = ""

        for c in text4:
            c_cat = uc.category(c)

            if c_cat == "Pd":
                text5 += "-"
            else:
                text5 += c

        dto.setText(text5)
        return dto

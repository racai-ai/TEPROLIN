"""Contains all configuration variables for the TEPROLIN platform."""

import os

# Name of the configuration folder
_configFolderName = '.teprolin'

# The DiacRestore.py model file
DIACMODELFILE = os.path.expanduser("~") + \
    os.sep + _configFolderName + \
    os.sep + "diac.model.newsty"

DIACWFREQFILE = os.path.expanduser("~") + \
    os.sep + _configFolderName + \
    os.sep + "ro-marcell-freq.txt"

# Path to tbl.wordform.ro.v85 lexicon file
# Used by NLP-Cube to do better lemmatization
TBLWORDFORMFILE = os.path.expanduser("~") + \
    os.sep + _configFolderName + \
    os.sep + 'res' + os.sep + 'ro' + \
    os.sep + 'tbl.wordform.ro.v85'

# Used by NLP-Cube to map MSDs to CTAGs
CTAG2MSDMAPFILE = os.path.expanduser("~") + \
    os.sep + _configFolderName + \
    os.sep + 'res' + os.sep + 'ro' + \
    os.sep + 'msdtag.ro.map'

# Used by BioNER NLP-Cube instance
BIONERMODELNAME = os.path.expanduser("~") + \
    os.sep + _configFolderName + \
    os.sep + 'bioner' + os.sep + "ro" + \
    os.sep + 'tagger' + os.sep + 'bioro_skip.200.1.5'

BIONERWORDEMBEDFILE = os.path.expanduser("~") + \
    os.sep + _configFolderName + \
    os.sep + 'bioner' + os.sep + "ro" + \
    os.sep + 'embeddings' + os.sep + 'bioro_skip.200.1.5.vec'

# For tpi.py (Adriana Stan)
SYLL_MODEL = os.path.expanduser("~") + \
    os.sep + _configFolderName + os.sep + \
    "models" + os.sep + "syllable_model_DT2.model"

ACCENT_MODEL = os.path.expanduser("~") + \
    os.sep + _configFolderName + os.sep + \
    "models" + os.sep + "accent_model_DT2.model"

PHONETIC_MODEL = os.path.expanduser("~") + \
    os.sep + _configFolderName + os.sep + \
    "models" + os.sep + "phonetic_ALV_2lr.model"

DICTIONARY = os.path.expanduser("~") + \
    os.sep + _configFolderName + os.sep + \
    "dict" + os.sep + "manual.dict"

ACRONYM_FILE = os.path.expanduser("~") + \
    os.sep + _configFolderName + os.sep + \
    "dict" + os.sep + "acronyms.txt"

ABBREVIATIONS_FILE = os.path.expanduser("~") + \
    os.sep + _configFolderName + os.sep + \
    "dict" + os.sep + "abbreviations.txt"

UDPIPEMODELFILE = os.path.expanduser("~") + \
    os.sep + _configFolderName + os.sep + \
    "udpipe" + os.sep + "romanian-rrt-ud-2.5-191206.udpipe"

# Provided by Vasile; localhost for the Docker container.
GENERALNERURL = 'http://89.38.230.23/ner/ner.php'

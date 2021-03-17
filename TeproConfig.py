"""Contains all configuration variables for the TEPROLIN platform."""

import os

# Name of the configuration folder
TEPROLIN_RESOURCES_FOLDER = os.path.expanduser("~") + os.sep + '.teprolin'

# The DiacRestore.py model file
DIACMODELFILE = TEPROLIN_RESOURCES_FOLDER + \
    os.sep + "diac.model.newsty"

DIACWFREQFILE = TEPROLIN_RESOURCES_FOLDER + \
    os.sep + "ro-marcell-freq.txt"

# Path to tbl.wordform.ro.v85 lexicon file
# Used by NLP-Cube to do better lemmatization
TBLWORDFORMFILE = TEPROLIN_RESOURCES_FOLDER + \
    os.sep + 'res' + os.sep + 'ro' + \
    os.sep + 'tbl.wordform.ro.v85'

# Used by NLP-Cube to map MSDs to CTAGs
CTAG2MSDMAPFILE = TEPROLIN_RESOURCES_FOLDER + \
    os.sep + 'res' + os.sep + 'ro' + \
    os.sep + 'msdtag.ro.map'

# Used by BioNER NLP-Cube instance
BIONERMODELNAME = TEPROLIN_RESOURCES_FOLDER + \
    os.sep + 'bioner' + os.sep + "ro" + \
    os.sep + 'tagger' + os.sep + 'bioro_skip.200.1.5'

BIONERWORDEMBEDFILE = TEPROLIN_RESOURCES_FOLDER + \
    os.sep + 'bioner' + os.sep + "ro" + \
    os.sep + 'embeddings' + os.sep + 'bioro_skip.200.1.5.vec'

UDPIPEMODELFILE = TEPROLIN_RESOURCES_FOLDER + os.sep + \
    "udpipe" + os.sep + "romanian-rrt-ud-2.5-191206.udpipe"

# Provided by Vasile; localhost for the Docker container.
GENERALNERURL = 'http://89.38.230.23/ner/ner.php'

# Automatically set the the Dockerfile build file
if os.environ.get('TEPROLIN_DOCKER') is not None:
    GENERALNERURL = 'http://127.0.0.1/ner/ner.php'

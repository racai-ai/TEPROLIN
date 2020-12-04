import sys
import re
import inspect
from pathlib import Path

class Encodings(object):
    def __init__(self):
        self.word_list = {}
        self.char2int = {}
        self.label2int = {}
        self.labels=[]
        self.word2int={}
        self.upos2int={}
        self.xpos2int={}
        self.attrs2int={}
        self.upos_list=[]
        self.xpos_list=[]
        self.attrs_list=[]
        self.characters=[]

    def load(self, filename):
        """We only read character2int, labels, holistic words and label2int here.
        word_list should be recomputed for every dataset (if deemed necessary)."""

        with open(filename, mode = 'r', encoding = 'utf-8') as f:
            line = f.readline()
            num_labels = int(line.split(" ")[1])

            print("{0}.{1}[{2}]: loading labels {3!s}".\
                format(
                    Path(inspect.stack()[0].filename).stem,
                    inspect.stack()[0].function,
                    inspect.stack()[0].lineno,
                    num_labels
                ), file = sys.stderr, flush = True)
            
            self.labels = [""] * num_labels
            
            for _ in range(num_labels):
                line = f.readline()
                parts = line.split("\t")
                key = parts[0]
                value = int(parts[1])
                self.label2int[key] = value
                self.labels[value] = key

            line = f.readline()
            num_characters = int(line.split(" ")[1])
            self.characters = [""] * num_characters

            print("{0}.{1}[{2}]: loading characters {3!s}".\
                format(
                    Path(inspect.stack()[0].filename).stem,
                    inspect.stack()[0].function,
                    inspect.stack()[0].lineno,
                    num_characters
                ), file = sys.stderr, flush = True)
            
            for _ in range(num_characters):
                line = f.readline()
                parts = line.split("\t")
                key = parts[0]
                value = int(parts[1])
                self.char2int[key] = value
                self.characters[value] = key

            line = f.readline()
            num_words = int(line.split(" ")[1])

            print("{0}.{1}[{2}]: loading words {3!s}".\
                format(
                    Path(inspect.stack()[0].filename).stem,
                    inspect.stack()[0].function,
                    inspect.stack()[0].lineno,
                    num_words
                ), file = sys.stderr, flush = True)

            for _ in range(num_words):
                line = f.readline()
                parts = line.split("\t")
                key = parts[0]
                value = int(parts[1])
                self.word2int[key] = value

            #morphological attributes
            line = f.readline()
            num_labels = int(line.split(" ")[1])

            print("{0}.{1}[{2}]: loading upos {3!s}".\
                format(
                    Path(inspect.stack()[0].filename).stem,
                    inspect.stack()[0].function,
                    inspect.stack()[0].lineno,
                    num_labels
                ), file = sys.stderr, flush = True)
            
            self.upos_list = [""] * num_labels

            for _ in range(num_labels):
                line = f.readline()
                parts = line.split("\t")
                key = parts[0]
                value = int(parts[1])
                self.upos2int[key] = value
                self.upos_list[value] = key

            line = f.readline()
            num_labels = int(line.split(" ")[1])
            self.xpos_list = [""] * num_labels

            print("{0}.{1}[{2}]: loading xpos {3!s}".\
                format(
                    Path(inspect.stack()[0].filename).stem,
                    inspect.stack()[0].function,
                    inspect.stack()[0].lineno,
                    num_labels
                ), file = sys.stderr, flush = True)

            for _ in range(num_labels):
                line = f.readline()
                parts = line.split("\t")
                key = parts[0]
                value = int(parts[1])
                self.xpos2int[key] = value
                self.xpos_list[value] = key

            line = f.readline()
            num_labels = int(line.split(" ")[1])
            self.attrs_list= [""] * num_labels

            print("{0}.{1}[{2}]: loading attrs {3!s}".\
                format(
                    Path(inspect.stack()[0].filename).stem,
                    inspect.stack()[0].function,
                    inspect.stack()[0].lineno,
                    num_labels
                ), file = sys.stderr, flush = True)

            for _ in range(num_labels):
                line = f.readline()
                parts = line.split("\t")
                key = parts[0]
                value = int(parts[1])
                self.attrs2int[key] = value
                self.attrs_list[value] = key

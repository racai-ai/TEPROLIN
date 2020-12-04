import sys
import inspect
from pathlib import Path

class WordEmbeddings:
    def __init__(self):
        self.word2vec = {}
        self.word2ofs = {}
        self.word_embeddings_size = 0
        self.num_embeddings = 0
        self.cache_only = False
        self.file_pointer = None

    def read_from_file(self, word_embeddings_file, word_list):
        self.word2vec = {}
        self.num_embeddings = 0
        
        if word_list is None:
            self.cache_only = True

        with open(word_embeddings_file, mode = 'r', encoding= 'utf-8') as f:
            first_line = True

            while True:
                ofs = f.tell()
                line = f.readline()
                
                if line == '':
                    break
                
                line = line.replace("\n", "").replace("\r", "")
                
                if first_line:
                    first_line = False
                else:
                    self.num_embeddings += 1

                    if self.num_embeddings % 10000 == 0:
                        print("{0}.{1}[{2}]: scanned {3!s} word embeddings and added {4!s}".\
                            format(
                                Path(inspect.stack()[0].filename).stem,
                                inspect.stack()[0].function,
                                inspect.stack()[0].lineno,
                                self.num_embeddings,
                                len(self.word2vec)
                            ), file = sys.stderr, flush = True)

                    parts = line.split(" ")
                    word = parts[0]

                    if self.cache_only:
                        self.word2ofs[word] = ofs
                    elif word in word_list:
                        embeddings = [float(0)] * (len(parts) - 2)

                        for zz in range(len(parts) - 2):
                            embeddings[zz] = float(parts[zz + 1])

                        self.word2vec[word] = embeddings

                    self.word_embeddings_size = len(parts) - 2

        if self.cache_only:
            self.file_pointer = open(word_embeddings_file, mode = 'r', encoding = 'utf-8')

    def get_word_embeddings(self, word):
        word = word.lower()

        if self.cache_only:
            if word in self.word2ofs:
                self.file_pointer.seek(self.word2ofs[word])
                line = self.file_pointer.readline()
                parts = line.split(" ")
                embeddings = [float(0)] * (len(parts) - 2)

                for zz in range(len(parts) - 2):
                    embeddings[zz] = float(parts[zz + 1])

                return (embeddings, True)
            else:
                return (None, False)
        elif word in self.word2vec:
            return (self.word2vec[word], True)
        else:
            return (None, False)

class ConllEntry:
    def __init__(self, index, word, lemma, upos, xpos, attrs, head, label, deps):
        self.index, self.is_compound_entry = self._int_try_parse(index)
        self.word = word
        self.lemma = lemma
        self.upos = upos
        self.xpos = xpos
        self.attrs = attrs
        self.head, _ = self._int_try_parse(head)
        self.label = label
        self.deps = deps

    def _int_try_parse(self, value):
        try:
            return int(value), False
        except ValueError:
            return value, True

import dynet as dy
import numpy as np
import random

from bioner.generic_networks.character_embeddings import CharacterNetwork
from bioner.generic_networks.utils import orthonormal_VanillaLSTMBuilder

class BDRNNTagger:
    def __init__(self, tagger_config, encodings, embeddings, aux_softmax_weight = 0.2):
        self.config = tagger_config
        self.encodings = encodings
        self.embeddings = embeddings

        self.model = dy.Model()
        self.trainer = dy.AdamTrainer(self.model)  # dy.MomentumSGDTrainer(self.model)
        self.trainer.set_sparse_updates(False)
        self.character_network = \
            CharacterNetwork(
                100, encodings, rnn_size = 200, rnn_layers = 1,
                embeddings_size = self.embeddings.word_embeddings_size,
                model = self.model)

        self.unknown_word_embedding = self.model.add_lookup_parameters((1, self.embeddings.word_embeddings_size))
        self.holistic_word_embedding = \
            self.model.add_lookup_parameters((len(encodings.word2int), self.embeddings.word_embeddings_size))

        self.char_proj_w = self.model.add_parameters((self.config.input_size, self.embeddings.word_embeddings_size))
        self.emb_proj_w = self.model.add_parameters((self.config.input_size, self.embeddings.word_embeddings_size))
        self.hol_proj_w = self.model.add_parameters((self.config.input_size, self.embeddings.word_embeddings_size))

        self.bdrnn_fw = []
        self.bdrnn_bw = []
        rnn_input_size = self.config.input_size #self.embeddings.word_embeddings_size

        aux_softmax_input_size = 0
        index = 0

        for layer_size in self.config.layers:
            self.bdrnn_fw.append(orthonormal_VanillaLSTMBuilder(1, rnn_input_size, layer_size, self.model))
            self.bdrnn_bw.append(orthonormal_VanillaLSTMBuilder(1, rnn_input_size, layer_size, self.model))
            rnn_input_size = layer_size * 2
            index += 1

            if index == self.config.aux_softmax_layer:
                aux_softmax_input_size = rnn_input_size

        self.mlps = []

        for _ in range(3):  # upos, xpos and attrs
            mlp_w = []
            mlp_b = []
            input_sz = self.config.layers[-1] * 2

            for l_size in self.config.presoftmax_mlp_layers:
                mlp_w.append(self.model.add_parameters((l_size, input_sz)))
                mlp_b.append(self.model.add_parameters((l_size)))
                input_sz = l_size

            self.mlps.append([mlp_w, mlp_b])

        softmax_input_size = self.config.presoftmax_mlp_layers[-1]

        self.softmax_upos_w = self.model.add_parameters((len(self.encodings.upos2int), softmax_input_size))
        self.softmax_upos_b = self.model.add_parameters((len(self.encodings.upos2int)))
        self.softmax_xpos_w = self.model.add_parameters((len(self.encodings.xpos2int), softmax_input_size))
        self.softmax_xpos_b = self.model.add_parameters((len(self.encodings.xpos2int)))
        self.softmax_attrs_w = self.model.add_parameters((len(self.encodings.attrs2int), softmax_input_size))
        self.softmax_attrs_b = self.model.add_parameters((len(self.encodings.attrs2int)))

        self.aux_softmax_upos_w = self.model.add_parameters((len(self.encodings.upos2int), aux_softmax_input_size))
        self.aux_softmax_upos_b = self.model.add_parameters((len(self.encodings.upos2int)))
        self.aux_softmax_xpos_w = self.model.add_parameters((len(self.encodings.xpos2int), aux_softmax_input_size))
        self.aux_softmax_xpos_b = self.model.add_parameters((len(self.encodings.xpos2int)))
        self.aux_softmax_attrs_w = self.model.add_parameters((len(self.encodings.attrs2int), aux_softmax_input_size))
        self.aux_softmax_attrs_b = self.model.add_parameters((len(self.encodings.attrs2int)))

        self.aux_softmax_weight = aux_softmax_weight

    def tag(self, seq):
        dy.renew_cg()
        softmax_list, aux_softmax_list = self._predict(seq)
        label_list = []

        for softmax in softmax_list:
            label_list.append([self.encodings.upos_list[np.argmax(softmax[0].npvalue())],
                               self.encodings.xpos_list[np.argmax(softmax[1].npvalue())],
                               self.encodings.attrs_list[np.argmax(softmax[2].npvalue())]])
        return label_list

    def _predict(self, seq, runtime = True):
        softmax_list = []
        aux_softmax_list = []
        x_list = []

        for entry in seq:
            word = entry.word
            char_emb, _ = self.character_network.compute_embeddings(word, runtime = runtime)

            word_emb, found = self.embeddings.get_word_embeddings(word)

            if not found:
                word_emb = self.unknown_word_embedding[0]
            else:
                word_emb = dy.inputVector(word_emb)

            holistic_word = word.lower()

            if holistic_word in self.encodings.word2int:
                hol_emb = self.holistic_word_embedding[self.encodings.word2int[holistic_word]]
            else:
                hol_emb = self.holistic_word_embedding[self.encodings.word2int['<UNK>']]

            proj_emb = self.emb_proj_w.expr() * word_emb
            proj_hol = self.hol_proj_w.expr() * hol_emb
            proj_char = self.char_proj_w.expr() * char_emb

            if runtime:
                x_list.append(dy.tanh(proj_char + proj_emb + proj_hol))
            else:
                p1 = random.random()
                p2 = random.random()
                p3 = random.random()
                m1 = 1
                m2 = 1
                m3 = 1

                if p1 < self.config.input_dropout_prob:
                    m1 = 0
                if p2 < self.config.input_dropout_prob:
                    m2 = 0
                if p3 < self.config.input_dropout_prob:
                    m3 = 0

                scale = 1.0

                if m1 + m2 + m3 > 0:
                    scale = float(3) / (m1 + m2 + m3)

                m1 = dy.scalarInput(m1)
                m2 = dy.scalarInput(m2)
                m3 = dy.scalarInput(m3)
                scale = dy.scalarInput(scale)
                x_list.append(dy.tanh((proj_char * m1 + proj_emb * m2 + proj_hol * m3) * scale))

        # BDLSTM
        rnn_outputs = []

        for fw, bw, dropout in zip(self.bdrnn_fw, self.bdrnn_bw, self.config.layer_dropouts):
            fw_list = fw.initial_state().transduce(x_list)
            bw_list = list(reversed(bw.initial_state().transduce(reversed(x_list))))
            x_list = [dy.concatenate([x_fw, x_bw]) for x_fw, x_bw in zip(fw_list, bw_list)]

            if runtime:
                x_out = x_list
            else:
                x_out = [dy.dropout(x, dropout) for x in x_list]

            rnn_outputs.append(x_out)

        # SOFTMAX
        mlp_output = []

        for x in rnn_outputs[-1]:
            pre_softmax = []

            for iMLP in range(3):
                mlp_w = self.mlps[iMLP][0]
                mlp_b = self.mlps[iMLP][1]
                inp = x

                for w, b, drop, in zip(mlp_w, mlp_b, self.config.presoftmax_mlp_dropouts):
                    inp = dy.tanh(w.expr() * inp + b.expr())

                    if not runtime:
                        inp = dy.dropout(inp, drop)

                pre_softmax.append(inp)
            mlp_output.append(pre_softmax)

        for softmax_inp, aux_softmax_inp in zip(mlp_output, rnn_outputs[self.config.aux_softmax_layer - 1]):
            softmax_list.append([dy.softmax(self.softmax_upos_w.expr() * softmax_inp[0] + self.softmax_upos_b.expr()),
                                 dy.softmax(self.softmax_xpos_w.expr() * softmax_inp[1] + self.softmax_xpos_b.expr()),
                                 dy.softmax(
                                     self.softmax_attrs_w.expr() * softmax_inp[2] + self.softmax_attrs_b.expr())])
            aux_softmax_list.append(
                [dy.softmax(self.aux_softmax_upos_w.expr() * aux_softmax_inp + self.aux_softmax_upos_b.expr()),
                 dy.softmax(self.aux_softmax_xpos_w.expr() * aux_softmax_inp + self.aux_softmax_xpos_b.expr()),
                 dy.softmax(self.aux_softmax_attrs_w.expr() * aux_softmax_inp + self.aux_softmax_attrs_b.expr())])

        return softmax_list, aux_softmax_list
    
    def load(self, path):
        self.model.populate(path)
        

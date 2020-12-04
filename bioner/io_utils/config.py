import sys
import inspect
from pathlib import Path
        
class TaggerConfig:
    def __init__(self):
        print("{0}.{1}[{2}]: reading configuration...".\
            format(
                Path(inspect.stack()[0].filename).stem,
                inspect.stack()[0].function,
                inspect.stack()[0].lineno
            ), file = sys.stderr, flush = True)

        self.layers = [200, 200]
        self.layer_dropouts = [0.5, 0.5]
        self.aux_softmax_layer = 1
        self.valid = True
        self.input_dropout_prob = 0.33
        self.presoftmax_mlp_layers = [500]
        self.presoftmax_mlp_dropouts = [0.5]
        self.input_size = 100

        print("{0}.{1}[{2}]: INPUT SIZE: {3!s}".\
            format(
                Path(inspect.stack()[0].filename).stem,
                inspect.stack()[0].function,
                inspect.stack()[0].lineno,
                self.input_size
            ), file = sys.stderr, flush = True)

        print("{0}.{1}[{2}]: LAYERS: {3!s}".\
            format(
                Path(inspect.stack()[0].filename).stem,
                inspect.stack()[0].function,
                inspect.stack()[0].lineno,
                self.layers
            ), file = sys.stderr, flush = True)

        print("{0}.{1}[{2}]: LAYER DROPOUTS: {3!s}".\
            format(
                Path(inspect.stack()[0].filename).stem,
                inspect.stack()[0].function,
                inspect.stack()[0].lineno,
                self.layer_dropouts
            ), file = sys.stderr, flush = True)

        print("{0}.{1}[{2}]: AUX SOFTMAX POSITION: {3!s}".\
            format(
                Path(inspect.stack()[0].filename).stem,
                inspect.stack()[0].function,
                inspect.stack()[0].lineno,
                self.aux_softmax_layer
            ), file = sys.stderr, flush = True)

        print("{0}.{1}[{2}]: INPUT DROPOUT PROB: {3!s}".\
            format(
                Path(inspect.stack()[0].filename).stem,
                inspect.stack()[0].function,
                inspect.stack()[0].lineno,
                self.input_dropout_prob
            ), file = sys.stderr, flush = True)

        print("{0}.{1}[{2}]: PRESOFTMAX MLP LAYERS: {3!s}".\
            format(
                Path(inspect.stack()[0].filename).stem,
                inspect.stack()[0].function,
                inspect.stack()[0].lineno,
                self.presoftmax_mlp_layers
            ), file = sys.stderr, flush = True)

        print("{0}.{1}[{2}]: PRESOFTMAX MLP DROPOUT: {3!s}".\
            format(
                Path(inspect.stack()[0].filename).stem,
                inspect.stack()[0].function,
                inspect.stack()[0].lineno,
                self.presoftmax_mlp_dropouts
            ), file = sys.stderr, flush = True)

        if self.aux_softmax_layer > len(self.layers) - 1 or \
           self.aux_softmax_layer == 0:
            print("{0}.{1}[{2}]: configuration error: aux softmax layer must be placed after the first layer and before the final one.".\
                format(
                    Path(inspect.stack()[0].filename).stem,
                    inspect.stack()[0].function,
                    inspect.stack()[0].lineno
                ), file = sys.stderr, flush = True)

            self.valid = False

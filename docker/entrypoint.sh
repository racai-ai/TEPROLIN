#!/bin/sh

export PATH=$JAVA_HOME/bin:$PATH
/ner/fastText-0.1.0-mod/fasttext server /ner/corola.300.20.5.bin 8001 &
/ner/ner_server.sh &
cd /teprolin && ./start-ws.sh
/usr/sbin/apachectl -D FOREGROUND

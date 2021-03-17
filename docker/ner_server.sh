#!/bin/sh

cd /ner

java -cp "stanford-ner-2018-10-16-mod/classes:../stanford-ner-2018-10-16-mod/lib/*" \
    -mx10g ner_server \
    -prop prop_ner_clean.server

#!/bin/bash

UWSGICMD=uwsgi

for P in 5010 5011 5012; do
    $UWSGICMD --stop uwsgi-$P.pid
    echo "Server stopped on port $P."
done

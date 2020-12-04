#!/bin/bash

UWSGICMD=uwsgi

for P in 5010 5011 5012; do
    rm -fv uwsgi-$P.pid ws-$P.log
    $UWSGICMD \
      --http 0.0.0.0:$P \
      --wsgi-file TeproREST.py \
      --callable app \
      --pidfile uwsgi-$P.pid \
      --master --processes 1 \
      --harakiri 600 \
      --socket-timeout 600 \
      --min-worker-lifetime 600 \
      --http-timeout 600 \
      --buffer-size 32768 \
      --post-buffering 32768 \
      --logto ws-$P.log &
    echo "Server started on port $P."
done

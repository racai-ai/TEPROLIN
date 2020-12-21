#!/bin/bash

# Because of NLP-Cube, we only start the server single threaded.
# embeddings.get_word_embeddings(self, word) does a seek in a file
# and, if the process is forked, the file descriptor is shared.
# Thus, seek does not work if not synchronized.

# Assumed to be in PATH in the venv/bin folder
UWSGICMD=uwsgi
rm -fv uwsgi.pid ws.log
$UWSGICMD \
  --http 0.0.0.0:5000 \
  --wsgi-file TeproREST.py \
  --callable app \
  --pidfile uwsgi.pid \
  --master --processes 1 \
  --harakiri 600 \
  --socket-timeout 600 \
  --min-worker-lifetime 600 \
  --http-timeout 600 \
  --buffer-size 32768 \
  --post-buffering 32768 \
  --logto ws.log &
echo "Server started."

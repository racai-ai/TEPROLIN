#!/bin/bash

UWSGICMD=uwsgi
$UWSGICMD --stop uwsgi.pid
echo "Server stopped."

#!/bin/bash
set -x

DURATION=${1}

docker compose up traefik crowdsec echo -d

CSPID=$(pgrep crowdsec)

docker compose up k6 -d

timestamp=$(date +%s)

psrecord $CSPID --plot plot_$timestamp.png --interval 0.1 --duration $DURATION
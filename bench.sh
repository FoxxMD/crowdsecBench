#!/bin/bash

trap 'exit 0;' SIGHUP SIGINT

printf 'Starting traefik and echo...\n'
docker compose up traefik echo -d

printf 'Starting crowdsec container...\n'
docker compose up crowdsec -d

CS_PID=$(pgrep crowdsec --newest | head -n 1)
while [ -z "$CS_PID" ]
do
    printf 'Waiting for crowdsec to finish starting up...\n'
    sleep 1
    CS_PID=$(pgrep crowdsec --newest | head -n 1)
done
printf 'Crowdsec started! Waiting a few seconds for CPU to settle...\n'
sleep 2

printf 'Starting goeffel capture of crowdsec PID %s \n' "$CS_PID"
docker compose run --rm --no-TTY goeffel goeffel --pid $CS_PID &

printf 'Starting k6\n'
docker compose up k6 -d

docker compose wait k6
printf 'k6 container exited!\n'

printf 'Stopping crowdsec\n'
docker compose down crowdsec

printf 'Waiting for goeffel to exit...\n'
docker compose wait goeffel

DATA=$(cd ./data/goeffel && ls -t1 *.hdf5 |  head -n 1)

timestamp=$(date +%s)

printf 'Generating plot for %s\n' "$DATA"

docker compose run --rm --no-TTY goeffel goeffel-analysis flexplot \
--series $DATA host \
--column proc_cpu_util_percent_total \
'CPU util (total) / %' \
"Crowdsec Web Traffic Load $timestamp" 5 \
--subtitle '50 concurrent requests, measured with Goeffel' \
--legend-loc 'upper right' \
--mean-style solid \
--custom-y-limit 0 100
#!/bin/bash

CMD=${1:-goeffel}
CMD_ANALYSIS="${CMD}-analysis"

if ! command -v $CMD >/dev/null 2>&1
then
    echo "$CMD could not be found, please make sure it is installed and this shell can access it."
    exit 1
fi

## https://askubuntu.com/a/970898
if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi

if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

trap 'exit 0;' SIGHUP SIGINT SIGKILL

printf 'Starting traefik and echo...\n'
sudo -u $real_user docker compose up traefik echo -d

printf 'Starting crowdsec container...\n'
sudo -u $real_user docker compose up crowdsec -d

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
$CMD --pid $CS_PID --no-system-metrics --label crowdsec &
G_PID=$!

printf 'Starting k6\n'
sudo -u $real_user docker compose up k6 -d

#printf 'Waiting for k6 to finish...\n'
docker compose wait k6
printf 'k6 container exited!\n'

printf 'Stopping crowdsec\n'
sudo -u $real_user docker compose down crowdsec

while test -d /proc/$G_PID; do
     printf 'Waiting for goeffel to finish...\n'
     sleep 1
done

DATA=$(ls -t1 *.hdf5 |  head -n 1)

timestamp=$(date +%s)

printf 'Generating plot for %s\n' "$DATA"

sudo -u $real_user $CMD_ANALYSIS flexplot \
--series $DATA host \
--column proc_cpu_util_percent_total \
'CPU util (total) / %' \
"Crowdsec Web Traffic Load $timestamp" 5 \
--subtitle '50 concurrent requests, measured with Goeffel' \
--legend-loc 'upper right' \
--mean-style solid \
--custom-y-limit 0 100
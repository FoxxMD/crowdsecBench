#!/bin/sh
## https://theholyjava.wordpress.com/2018/10/17/monitoring-process-memory-cpu-usage-with-top-and-plotting-it-with-gnuplot/
##
## BEWARE: Check with your impl. of top what exactly it returns, it migth differ from mine
##
# Usage: ./monitor-usage.sh <PID of the process>
# Output: top.dat with lines such as `1539689171 305m 2.0`, i.e. unix time - memory with m suffix - CPU load in %
# To plot the output, see https://gist.github.com/holyjak/1b58dedae3207b4a56c9abcde5f3fdb5
export PID=$1
rm top.dat
while true; do top -p $PID -bn 1 -em | grep -E '^ *[0-9]+' | awk -v now=$(date +%s.%N) '{print now,$6,$9}' >> top.dat; done
# top: -p <pid> target process, -b batch mode, -n 1 run once; -em display mem in MB
# egrep extracts the line starting with the pid, with the metrics
# awk prepends a date and extracts columns 6 (RES = residential memory, ie RAM) and 9, which should be the memory and cpu load
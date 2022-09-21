#!/usr/bin/env bash

FILENAME=${1:?"must provide a file path"}
LINES=${2:-100}
[[ $LINES == "0" ]] && LINES=$(wc -l < $FILENAME)

cut -d " " -f2 $FILENAME | sort -n | uniq -c | sort -nr | head -n $LINES

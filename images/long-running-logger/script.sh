#!/bin/bash

# Read script parameters
while getopts ":m:" opt; do
  case $opt in
    m)
      execution_minutes="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG, aborting..." >&2
      exit 1
      ;;
  esac
done

execution_seconds=$(($execution_minutes*60))
echo "Script will try to run for ${execution_minutes} minutes" \
    "== ${execution_seconds} seconds!" >&1

# Run and log for specified amount of time
SECONDS=0
while [ ${execution_seconds} -gt ${SECONDS} ]
do
    sleep 30
    echo "${SECONDS}/${execution_seconds} seconds elapsed..." >&1
done

echo "SUCCESS --> ${execution_minutes} == ${execution_seconds} elapsed!" >&1
#!/bin/bash

execution_seconds=$((${EXECUTION_MINUTES}*60))
echo "Script will try to run for ${EXECUTION_MINUTES} minutes" \
    "== ${execution_seconds} seconds!" >&1

# Run and log for specified amount of time
SECONDS=0
while [ ${execution_seconds} -gt ${SECONDS} ]
do
    sleep 30
    echo "${SECONDS}/${execution_seconds} seconds elapsed..." >&1
done

echo "SUCCESS --> ${EXECUTION_MINUTES} == ${execution_seconds} elapsed!" >&1
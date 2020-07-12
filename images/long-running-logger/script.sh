#!/bin/bash

# Read script arguments
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

printf "Script will try to run for %d minutes!\n" "$execution_minutes"

# TODO Run and log for specified amount of time


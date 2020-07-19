#!/bin/bash

PORT="${PORT:-8080}"
echo "Listening on ${PORT}..."
nc -lk -p "${PORT}" -e "./cloudrun_script.sh"
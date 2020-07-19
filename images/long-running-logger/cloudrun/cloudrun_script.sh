#!/bin/bash

HEAD="$(cat <<EOF
HTTP/1.1 200 OK
Connection: keep-alive\r\n\r\n
EOF
)"

echo -en "$HEAD"

source ./script.sh
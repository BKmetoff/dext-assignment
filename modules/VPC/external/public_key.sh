#!/bin/bash

set -euo pipefail

# $1 == name of file
# $2 == current directory / 'path.module'
FILEPATH="$2/pem/$1.pem"

PUBLIC_KEY=$(ssh-keygen -y -f "$FILEPATH")

cat <<EOF
{
  "public_key": "$PUBLIC_KEY"
}
EOF
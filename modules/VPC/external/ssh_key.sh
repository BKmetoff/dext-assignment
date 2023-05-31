#!/bin/bash

set -euo pipefail

# $1 == /path/to/public/key
PUBLIC_KEY=$(cat $1)

cat <<EOF
{
  "public_key": "$PUBLIC_KEY"
}
EOF

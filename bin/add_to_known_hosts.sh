#!/bin/bash

set -e

for ip in "$@"
do
  ssh-keyscan -H $ip >> ~/.ssh/known_hosts
done

sleep 5

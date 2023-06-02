#!/bin/bash

for ip in "$@"
do
  ssh-keyscan -H $ip >> ~/.ssh/known_hosts
done

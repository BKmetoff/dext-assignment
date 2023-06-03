#!/bin/bash

set -e

# $1 == SSH_KEY_PATH
# $2 == ANSIBLE_PATH

ansible-playbook --private-key "$1" -u "ec2-user" -i "$2/hosts.ini" "$2/playbook.yaml"

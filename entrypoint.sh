#!/bin/bash


set -e

ANSIBLE_PATH="./ansible"
SSH_KEY_PATH="./ssh/id_rsa"

echo -e "\n=== Running Terraform ===\n"
./bin/run_terraform.sh
echo -e "\n=== Provisioning complete ===\n"


echo -e "\n=== Adding public ip to known hosts ===\n"
PUBLIC_IP=$(cat $ANSIBLE_PATH/hosts.ini | grep "[0-9]")
./bin/add_to_known_hosts.sh $PUBLIC_IP


echo -e "\n=== Running Ansible ===\n"
./bin/run_ansible.sh $SSH_KEY_PATH $ANSIBLE_PATH


echo -e "\n=== Done ==="
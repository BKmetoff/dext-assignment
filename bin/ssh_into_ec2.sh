#!/bin/bash

set -e

ssh -i ../ssh/id_rsa ec2-user@$1

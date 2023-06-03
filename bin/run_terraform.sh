#!/bin/bash

set -e

terraform plan -out=plan.out -compact-warnings
terraform apply "plan.out"

sleep 5
locals {
  # The name of the local AWS profile
  # that's authenticated in AWS.
  aws_profile  = "default"
  region       = "eu-west-1"
  project_name = "dext-assignment"

  web_server_count = 1

  ec2 = {
    # Amazon Linux 2
    # Kernel 5.10 AMI 2.0.20230515.0
    #x86_64 HVM gp2
    ami           = "ami-0e23c576dacf2e3df"
    instance_type = "t2.micro"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22"
    }
  }

  backend "s3" {
    key     = "dext-assignment-terraform-state.tfstate"
    bucket  = "dext-assignment-terraform-state"
    region  = "eu-west-1"
    encrypt = true
    acl     = "bucket-owner-full-control"
  }
}

provider "aws" {
  region  = local.region
  profile = local.aws_profile
}

module "vpc" {
  source = "./modules/VPC"

  name       = local.project_name
  aws_region = local.region

  vpc_cidr            = "10.0.0.0/16"
  public_subnets_cidr = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]

  ec2_web_server_count = local.web_server_count
}


module "ec2_web_server" {
  source = "./modules/EC2"
  count  = local.web_server_count

  region = local.region
  name   = local.project_name

  subnet_id          = element(module.vpc.public_subnet_ids[*], count.index)
  security_group_ids = [module.vpc.web_server_security_group_id]

  ec2_public_key = module.vpc.public_key_name

  instance_spec = {
    type = local.ec2.instance_type
    ami  = local.ec2.ami
  }

  depends_on = [module.vpc]
}

# ===================================
# Export public IPs of EC2 instances
# in an Ansible hosts.ini file format.

# The Ansible playbooks will read this IP
# and try to connect to it using
# the provisioned SSH key.

# The generated hosts.in file will be
# deleted when running 'terraform destroy'

resource "local_file" "ec2_public_ips" {
  filename = "${path.root}/ansible/hosts.ini"
  content  = <<-EOF
[webserver]
%{for ec2 in module.ec2_web_server[*]~}
${ec2.public_ips}
%{endfor~}
EOF

  depends_on = [module.ec2_web_server]
}

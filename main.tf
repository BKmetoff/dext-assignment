locals {
  region       = "eu-west-1"
  aws_profile  = "default" ## update with Dext AWS credentials
  project_name = "dext-assignment"

  web_server_count = 2
  db_count         = 1

  ec2 = {
    # Amazon Linux 2
    # Kernel 5.10 AMI 2.0.20230515.0
    #x86_64 HVM gp2
    ami           = "ami-0e23c576dacf2e3df"
    instance_type = "t2.micro"
    # ami = "ami-013d87f7217614e10" # CENTos
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

  ec2_web_server_count = local.web_server_count
}


module "ec2_web_server" {
  source = "./modules/EC2"

  count = local.web_server_count

  region = local.region
  name   = local.project_name

  private            = false
  subnet_id          = element(module.vpc.public_subnet_ids[*].id, count.index)
  security_group_ids = [module.vpc.security_group_id]
  ec2_public_key     = module.vpc.public_key_name

  instance_spec = {
    type = local.ec2.instance_type
    ami  = local.ec2.ami
  }

  depends_on = [module.vpc]
}

# Export public IPs of EC2 instances.
# Needed for Ansible playbook.
resource "local_file" "ec2_public_ips" {
  # file structure
  # [webserver]
  # ip.address.of.instance
  # ip.address.of.instance

  # [database]
  # ip.address.of.instance

  filename = "${path.root}/ansible/hosts.ini"
  content  = <<-EOF
[webserver]
%{for ec2 in module.ec2_web_server[*]~}
${ec2.public_ips[0]}
%{endfor~}

[database]
EOF

  depends_on = [module.ec2_web_server]
}


# module "ec2_database" {
#   source = "./modules/EC2"
#   count  = local.db_count

#   region = local.region
#   name   = local.project_name

#   private = true

#   subnet_id          = ""
#   security_group_ids = [""]

#   ec2_public_key = module.vpc.public_key_name

#   instance_spec = {
#     type = local.ec2.instance_type
#     ami  = local.ec2.ami
#   }

#   depends_on = [module.vpc]
# }

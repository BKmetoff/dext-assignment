locals {
  region       = "eu-west-1"
  aws_profile  = "default" ## update with Dext AWS credentials
  project_name = "dext-assignment"

  web_server_count = 2
  db_count         = 1

  ec2 = {
    instance_type = "t2.micro"
    ami           = "ami-04f7efe62f419d9f5"
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

  name       = "${local.region}-${local.project_name}"
  aws_region = local.region

  ec2_web_server_count = local.web_server_count
}


module "ec2_web_server" {
  source = "./modules/EC2"

  count = local.web_server_count

  region = local.region
  name   = local.project_name

  private   = false
  subnet_id = element(module.vpc.public_subnet_ids[*].id, count.index)

  security_group_ids = [module.vpc.security_group_id]

  instance_spec = {
    type = local.ec2.instance_type
    ami  = local.ec2.ami
  }

  depends_on = [module.vpc]
}

# module "ec2_database" {
#   source = "./modules/EC2"

#   private             = true
#   number_of_instances = 1
#   instance_type       = local.ec2.instance_type
#   ami                 = local.ec2.ami
#   subnet_id           = module.vpc.private_subnet_id
#   region              = local.region
#   name                = local.project_name

#   depends_on = [module.vpc]
# }

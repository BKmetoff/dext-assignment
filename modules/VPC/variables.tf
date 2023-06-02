variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
}

variable "name" {
  description = "A name to identify VPC-related resources by"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "ec2_web_server_count" {
  description = "How many web servers are to be provisioned"
  type        = number
}

variable "ec2_db_count" {
  description = "How many database instances are to be provisioned"
  type        = number
}

variable "private_subnets_cidr" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnets_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}


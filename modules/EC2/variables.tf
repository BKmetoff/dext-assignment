variable "private" {
  description = "Whether an EC2 instance should be exposed to the outside world"
  type        = bool
}

variable "instance_spec" {
  description = "The type of machines to launch"
  type = object({
    type = string
    ami  = string
  })
}

variable "subnet_id" {
  description = "The ID of the subnet instances should be placed in"
  type        = any
}

variable "security_group_ids" {
  description = "The IDs of the security groups instances should be associated with"
  type        = list(any)
}

variable "name" {
  description = "An identifier for EC2-related resources"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "ec2_public_key" {
  description = "The name of the ec2 key-pair used to shh into ec2 instances"
  type        = string
}

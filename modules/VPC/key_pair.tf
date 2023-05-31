# Inject local ssh key into the EC2 machines
# to allow Ansible to do its magic.

# Use 'ssh-keygen' to create an ssh key,
# name it `id_rsa`,
# store it in `/ssh`s

data "external" "env" {
  program = [
    "/bin/bash",
    "${path.module}/external/ssh_key.sh",
    "${path.root}/ssh/id_rsa.pub"
  ]
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.name
  public_key = data.external.env.result["public_key"]
}


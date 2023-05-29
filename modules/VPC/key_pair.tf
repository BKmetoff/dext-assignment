# Inject public_key using a pre-existing
# .pem file stored locally

# The name of the .pem file **must** be
# the same as the value of 'var.name',
# which is supplied in the 'locals' block in /main.tf

data "external" "env" {
  program = [
    "/bin/bash",
    "${path.module}/external/public_key.sh",
    var.name,
    path.module
  ]
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.name
  public_key = data.external.env.result["public_key"]
}


# ------- Latest Linux AMI ID -------
data "aws_ami" "latest_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
    web_ami = coalesce(var.web_ami, data.aws_ami.latest_linux.id)   # returns the first non null, non empty value from the list of arguments.
    app_ami = coalesce(var.app_ami, data.aws_ami.latest_linux.id)
}

# ------- web tier - Launch template and ASG -------

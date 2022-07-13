terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.48.0"
    }
  }
  backend "http" {}
}

provider "aws" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.SSH_PUBLIC_KEY
}

resource "aws_security_group" "l2tp" {
  name        = "l2tp-ipsec"
  description = "Allow all ports wich required for L2TP/IPSec to operate"
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value["description"]
      protocol    = ingress.value["protocol"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "l2tp-ipsec"
  }
}

resource "aws_instance" "L2TP-IPSec" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t3.micro"
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.l2tp.name]

  root_block_device {
    volume_size = "9"
  }

  tags = {
    Name = "L2TP-IPSec"
  }
}

resource "null_resource" "confifure-vpn-instance" {
  triggers = {
    instance_id = "${aws_instance.L2TP-IPSec.id}"
  }

  provisioner "local-exec" {
    # command = ""
    command = <<-EOT
      chmod o-w .;
      chmod 600 ${var.SSH_PRIVATE_KEY};
      echo ${aws_instance.L2TP-IPSec.public_ip} > hosts;
      ansible-playbook -u 'ubuntu' --private-key ${var.SSH_PRIVATE_KEY} --vault-password-file ${var.ANSIBLE_VAULT_PASSWD} setup.yml
    EOT
  }
}

output "instance_pub_ip" {
  description = "VM's Public IP"
  value       = aws_instance.L2TP-IPSec.public_ip
}

output "instance_priv_ip" {
  description = "VM's Public IP"
  value       = aws_instance.L2TP-IPSec.private_ip
}

output "instance_id" {
  description = "VM's ID"
  value       = aws_instance.L2TP-IPSec.id
}

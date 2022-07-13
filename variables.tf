variable "SSH_PUBLIC_KEY" {
  type = string
  description = "SSH public key for VPN instance"
}

variable "SSH_PRIVATE_KEY" {
  type = string
  description = "SSH private key file path"
}

variable "ANSIBLE_VAULT_PASSWD" {
  type = string
  description = "SSH private key file path"
}

variable "ingress_rules" {
  type = list(object({
    description = string
    protocol    = string
    from_port   = number
    to_port     = number
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "L2TP"
      protocol    = "udp"
      from_port   = 1701
      to_port     = 1701
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "IPSec IKE"
      protocol    = "udp"
      from_port   = 500
      to_port     = 500
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "IPSec"
      protocol    = "udp"
      from_port   = 4500
      to_port     = 4500
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "SSH"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

dev.tfvars

environment      = "dev"
region           = "eu-west-2"
instance_type    = "t3.micro"
ami_id           = "ami-0b45ae66668865cd6"
sg_name          = "nocomed-ec2-security-group-dev"
root_volume_size = 40 # or whatever size you want for dev


ec2.tf

terraform {
  backend "s3" {
    bucket  = "nocomed-dev-tfstatefiles-west2"
    key     = "ec2/ec2.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }

}

provider "aws" {
  region = var.region
}

# Fetch all VPCs in the region
data "aws_vpcs" "all_vpcs" {}

output "all_vpc_ids" {
  value = data.aws_vpcs.all_vpcs.ids
}

# Fetch subnets dynamically by their names using the tag:Name
data "aws_subnets" "private_subnets" {
  filter {
    name = "tag:Name"
    values = [
      "nocomed-${var.environment}-private-subnet-1",
      "nocomed-${var.environment}-private-subnet-2",
      "nocomed-${var.environment}-private-subnet-3"
    ]
  }
}

# Fetch the existing IAM role
data "aws_iam_role" "ec2_ssm_role" {
  name = "ec2_ssm_role" # The name of the existing IAM role
}

# Fetch the existing IAM instance profile
data "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2_ssm_profile" # The name of the existing IAM instance profile
}

resource "random_string" "random_suffix" {
  length  = 4
  special = false
  upper   = false
}


# Create a new security group
resource "aws_security_group" "ec2_security_group" {
  name        = "${var.sg_name}-${random_string.random_suffix.result}"
  description = "Allow inbound SSH and all outbound traffic"

  vpc_id = data.aws_vpcs.all_vpcs.ids[0]

  # Allow inbound SSH (port 22) from 0.0.0.0/0
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Restrict to your VPC
  }

  # Allow inbound HTTP (port 8080) from 0.0.0.0/0
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Restrict to your VPC
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nocomed-ec2-ssh-sg"
  }
}

# Launch the EC2 instance
resource "aws_instance" "ec2_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.private_subnets.ids[0]
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_ssm_profile.name
  key_name                    = "test"
  associate_public_ip_address = false

  # Attach the security group to the instance
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  root_block_device {
    volume_size = var.root_volume_size # Use the variable here
    volume_type = "gp2"                # or "gp3" for newer instances
  }

  tags = {
    Name = "nocomed-ec2-ssm-instance"
  }
}




vars.tf


variable "environment" {
  description = "The environment tag (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-2" # You can change the default region if needed
}

variable "instance_type" {
  description = "The instance type"
  type        = string
  default     = "t3.medium" # You can change the default region if needed
}

variable "ami_id" {
  description = "The Desired AMI"
  type        = string
  default     = "ami-0b45ae66668865cd6"
}

variable "sg_name" {
  description = "The name of the EC2 security group"
  type        = string
  default     = "nocomed-ec2-security-group" # You can provide a default value or pass it dynamically during terraform apply
}

variable "root_volume_size" {
  description = "The size of the root volume in GB"
  type        = number
  default     = 8 # Default size if not specified
}

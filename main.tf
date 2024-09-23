provider "aws" {
  region = "ap-south-1"  # Replace with your desired AWS region
}

# security group
resource "aws_security_group" "master" {
  vpc_id = "vpc-0f28bcc0b6a596b84"

# port 22 for ssh conection
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# port 3306 for db connection
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# open to all
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # "-1" represents all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "master-key-gen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the Key Pair of Kali Linux didn't have software
resource "aws_key_pair" "master-key-pair" {
  key_name   = var.keypair_name 
  public_key = tls_private_key.master-key-gen.public_key_openssh
}

# Exploitable Windows - HADOOP
resource "aws_instance" "Window_HADOOP" {
  ami           = "ami-0f191a2d39d240986"  # Replace with your desired AMI ID
  instance_type = "t3a.medium"  # Replace with your desired instance type
  key_name      = aws_key_pair.master-key-pair.key_name
  subnet_id     = "subnet-0fd31cfc06b1857a4"
  availability_zone = "ap-south-1a"

  security_groups = [aws_security_group.master.id]

  tags = {
    Name = var.instance_name2
  }
}

resource "local_file" "local_key_pair" {
  filename        = "${var.keypair_name}.pem"
  file_permission = "0400"
  content         = tls_private_key.master-key-gen.private_key_pem
}

output "pem_file_for_ssh" {
  value     = tls_private_key.master-key-gen.private_key_pem
  sensitive = true
}

output "Window_HADOOP_public_ip" {
  value = aws_instance.Window_HADOOP.public_ip
}

output "HADOOP_Windows_Username" {
  value = "Administrator"
}

output "HADOOP_Windows_Password" {
  value = "?2NCaNG&Ntz=q14nhH*YJrXHXsw(PW.("
}

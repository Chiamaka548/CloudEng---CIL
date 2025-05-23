variable "private_subnet_id" {}
variable "key_name" {}
variable "vpc_id" {}
variable "alb_sg_id" {}

resource "aws_security_group" "private_instance_sg" {
  name        = "private-instance-sg"
  description = "Allow HTTP from ALB and SSH from your IP"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ubuntu_private" {
  ami                    = "ami-084568db4383264d4"
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.private_instance_sg.id]
  user_data              = <<-EOF
                            #!/bin/bash
                            apt update -y
                            apt install nginx -y
                            systemctl start nginx
                            systemctl enable nginx
                            EOF

  tags = {
    Name = "ubuntu-private-nginx"
  }
}

output "instance_id" {
  value = aws_instance.ubuntu_private.id
}
output "private_ip" {
  value = aws_instance.ubuntu_private.private_ip
}

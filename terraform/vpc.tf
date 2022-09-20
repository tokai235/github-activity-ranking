resource "aws_vpc" "app" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

resource "aws_subnet" "subnet_public_1c" {
  vpc_id               = aws_vpc.app.id
  cidr_block           = "10.0.1.0/24"
  availability_zone = "ap-northeast-1c"
}

resource "aws_security_group" "ecs_task_sg" {
  name        = "ecs-task-sg"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.app.id

  ingress {
    description      = "Allow HTTPS from all"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow all"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.app_name}-sg"
  }
}
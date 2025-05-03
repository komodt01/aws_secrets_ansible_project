provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "ec2_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_secrets_role" {
  name = "EC2SecretsManagerAccess"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "secrets_access" {
  name        = "SecretsManagerRead"
  description = "Allows read access to Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["secretsmanager:GetSecretValue"],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_secrets_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

resource "aws_iam_instance_profile" "ec2_secrets_profile" {
  name = "EC2SecretsProfile"
  role = aws_iam_role.ec2_secrets_role.name
}

resource "aws_secretsmanager_secret" "ansible_secret" {
  name = "ansible-secret"
}

resource "aws_secretsmanager_secret_version" "ansible_secret_version" {
  secret_id     = aws_secretsmanager_secret.ansible_secret.id
  secret_string = jsonencode({
    APP_USER     = "ansibleuser",
    APP_PASSWORD = "SuperSecureP@ssw0rd"
  })
}

resource "aws_instance" "ansible_ec2" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.main_subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = "ansible"
  iam_instance_profile        = aws_iam_instance_profile.ec2_secrets_profile.name

  tags = {
    Name        = "AnsibleSecretsEC2"
    Project     = "AWS Secrets Manager + Ansible"
    Environment = "Demo"
  }
}
resource "aws_key_pair" "example-server-keypair" {
  key_name   = "${var.project}-server-keypair"
  public_key = file("account1.pub")
}
resource "aws_security_group" "ec2_sg" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = var.vpc_id
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
  tags = {
    Name = "aws-backup-ec2-security-group"
  }
}

resource "aws_instance" "example-server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  security_groups             = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.example-server-keypair.key_name
  associate_public_ip_address = var.attach_public_ip
  disable_api_termination     = false
  monitoring                  = false
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    volume_type           = "standard"
    volume_size           = 10
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name    = "${var.project}-${var.region}-server"
    Project = var.project
    Role    = "ec2"
    Backup  = "true"
  }
}
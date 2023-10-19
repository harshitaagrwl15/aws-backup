resource "aws_key_pair" "example-server-keypair" {
  key_name   = "${var.project}-server-keypair"
  public_key = file("account1.pub")
}

resource "aws_instance" "example-server" {
  ami                         = var.ami // Ubuntu 20.04 LTS
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.example-server-keypair.key_name
  associate_public_ip_address = var.attach_public_ip
  disable_api_termination     = false
  monitoring                  = true

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
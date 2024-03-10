resource "aws_vpc" "t-vpc" {
  cidr_block           = var.vpc-cidr-block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    environment = "dev"
  }
}

resource "aws_subnet" "t-subnet" {
  vpc_id                  = aws_vpc.t-vpc.id
  cidr_block              = var.subnet-cidr-block
  map_public_ip_on_launch = true

  tags = {
    environment = "dev"
  }
}

resource "aws_internet_gateway" "t-gw" {
  vpc_id = aws_vpc.t-vpc.id

  tags = {
    environment = "dev"
  }
}

resource "aws_route_table" "t-rt" {
  vpc_id = aws_vpc.t-vpc.id

  tags = {
    environment = "dev"
  }
}

resource "aws_route" "t-r" {
  route_table_id         = aws_route_table.t-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.t-gw.id
}

resource "aws_route_table_association" "t-rt-assoc" {
  subnet_id      = aws_subnet.t-subnet.id
  route_table_id = aws_route_table.t-rt.id
}

resource "aws_security_group" "t-sg" {
  name   = var.security-group-name
  vpc_id = aws_vpc.t-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "t-keypair" {
  key_name   = var.keypair-name
  public_key = file(var.pubkey-path)
}

resource "aws_instance" "t-ec2" {
  instance_type          = var.ec2-instance-type
  ami                    = data.aws_ami.t-ami.id
  key_name               = aws_key_pair.t-keypair.key_name
  vpc_security_group_ids = [aws_security_group.t-sg.id]
  subnet_id              = aws_subnet.t-subnet.id
  user_data              = file(var.init-script-path)

  provisioner "local-exec" {
    command = templatefile(
      var.host-OS != "windows" ? "./scripts/ssh-host-add.tpl" : "./scripts/windows-ssh-host-add.tpl",
      {
        hostname = self.public_ip,
        user     = "ubuntu",
        idfile   = var.private-key-path
      }
    )
    interpreter = var.host-OS != "windows" ? ["bash", "-c"] : ["Powershell", "-Command"]
  }

  tags = {
    environment = "dev"
  }
}
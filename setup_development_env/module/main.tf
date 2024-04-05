resource "aws_vpc" "development_env_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    environment = "dev"
  }
}

resource "aws_subnet" "development_env_subnet" {
  vpc_id                  = aws_vpc.development_env_vpc.id
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = true

  tags = {
    environment = "dev"
  }
}

resource "aws_internet_gateway" "development_env_internet_gw" {
  vpc_id = aws_vpc.development_env_vpc.id

  tags = {
    environment = "dev"
  }
}

resource "aws_route_table" "development_env_route_table" {
  vpc_id = aws_vpc.development_env_vpc.id

  tags = {
    environment = "dev"
  }
}

resource "aws_route" "development_env_route" {
  route_table_id         = aws_route_table.development_env_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.development_env_internet_gw.id
}

resource "aws_route_table_association" "development_env_route_table_assoc" {
  subnet_id      = aws_subnet.development_env_subnet.id
  route_table_id = aws_route_table.development_env_route_table.id
}

resource "aws_security_group" "development_env_security_group" {
  name   = var.security_group_name
  vpc_id = aws_vpc.development_env_vpc.id

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

resource "aws_key_pair" "development_env_key_pair" {
  key_name   = var.keypair_name
  public_key = file(var.pubkey_path)
}

resource "aws_instance" "development_env_instance" {
  instance_type          = var.ec2_instance_type
  ami                    = data.aws_ami.t_ami.id
  key_name               = aws_key_pair.development_env_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.development_env_security_group.id]
  subnet_id              = aws_subnet.development_env_subnet.id
  user_data              = file(var.init_script_path)

  provisioner "local-exec" {
    command = templatefile(
      var.host_OS != "windows" ? "./scripts/ssh_host_add.tpl" : "./scripts/windows_ssh_host_add.tpl",
      {
        hostname = self.public_ip,
        user     = "ubuntu",
        idfile   = var.private_key_path
      }
    )
    interpreter = var.host_OS != "windows" ? ["bash", "-c"] : ["Powershell", "-Command"]
  }

  tags = {
    environment = "dev"
  }
}
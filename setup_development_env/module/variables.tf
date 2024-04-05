variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block used to define the VPC"
}

variable "subnet_cidr_block" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block used to define a subnet in the defined VPC"
}

variable "ami_owners" {
  type        = list(string)
  default     = ["099720109477"] # owner id of public ubuntu22.04 LTS image.
  description = "owners' ids of AMI Images"
}

variable "security_group_name" {
  type        = string
  default     = "dev_sg"
  description = "name of the security group."
}

variable "keypair_name" {
  type        = string
  default     = "dev_keypair"
  description = "name of the keypair"
}

variable "pubkey_path" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "public key path"
}

variable "private_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa"
  description = "private key path"
}

variable "ec2_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type"
}

variable "init_script_path" {
  type        = string
  default     = "./scripts/init.sh"
  description = "path to the init script"
}

variable "host_OS" {
  type        = string
  default     = "windows"
  description = "OS of the host machine"
}
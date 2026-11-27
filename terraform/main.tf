data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu_24_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
  enable_nat_gateway = var.enable_nat_gateway
}

module "security_groups" {
  source = "./modules/security_groups"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

module "bastion" {
  source = "./modules/bastion"

  project_name      = var.project_name
  environment       = var.environment
  ami_id            = data.aws_ami.ubuntu_24_04.id
  instance_type     = var.ec2_instance_type
  key_name          = var.key_name
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_groups.bastion_sg_id
}

module "ec2_k8s" {
  source = "./modules/ec2_k8s"

  project_name      = var.project_name
  environment       = var.environment
  ami_id            = data.aws_ami.ubuntu_24_04.id
  instance_type     = var.ec2_instance_type
  key_name          = var.key_name
  subnet_ids        = module.vpc.private_app_subnet_ids
  security_group_id = module.security_groups.k8s_nodes_sg_id
  worker_count      = var.k8s_worker_count
}

module "rds" {
  source = "./modules/rds"

  project_name      = var.project_name
  environment       = var.environment
  subnet_ids        = module.vpc.private_db_subnet_ids
  security_group_id = module.security_groups.rds_sg_id
}

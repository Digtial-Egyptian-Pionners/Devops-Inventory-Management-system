variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Project prefix for resource naming"
  type        = string
  default     = "apex-inventory"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "key_name" {
  description = "Existing AWS EC2 Key Pair name"
  type        = string
  default     = "depi-task"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to the Bastion host"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ec2_instance_type" {
  description = "Free-tier EC2 instance type for Bastion and K8s nodes"
  type        = string
  default     = "t3.micro"
}

variable "k8s_worker_count" {
  description = "Number of Kubernetes worker EC2 instances"
  type        = number
  default     = 1
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets (not Free Tier; keep false for minimal free-tier validation)"
  type        = bool
  default     = false
}

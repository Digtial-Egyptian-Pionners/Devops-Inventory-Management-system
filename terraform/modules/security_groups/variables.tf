variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to Bastion (restrict to your public IP in production)."
  type        = string
  default     = "0.0.0.0/0"
}

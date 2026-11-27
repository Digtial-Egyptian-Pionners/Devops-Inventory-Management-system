variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "key_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "worker_count" {
  type    = number
  default = 1
}

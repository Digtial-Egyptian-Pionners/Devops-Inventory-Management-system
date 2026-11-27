variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "db_name" {
  type    = string
  default = "inventory_db"
}

variable "db_username" {
  type    = string
  default = "apex_admin"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "engine_version" {
  type    = string
  default = "16.15"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "bastion_public_ip" {
  description = "Public IP address of the Bastion host"
  value       = module.bastion.bastion_public_ip
}

output "k8s_master_private_ip" {
  description = "Private IP address of the Kubernetes control-plane EC2"
  value       = module.ec2_k8s.k8s_master_private_ip
}

output "k8s_worker_private_ips" {
  description = "Private IP addresses of the Kubernetes worker EC2s"
  value       = module.ec2_k8s.k8s_worker_private_ips
}

output "rds_endpoint" {
  description = "Amazon RDS PostgreSQL endpoint (host:port)"
  value       = module.rds.rds_endpoint
}

output "rds_address" {
  description = "Amazon RDS PostgreSQL hostname"
  value       = module.rds.rds_address
}

output "rds_secret_arn" {
  description = "AWS Secrets Manager ARN storing RDS credentials"
  value       = module.rds.rds_secret_arn
}

output "rds_secret_name" {
  description = "AWS Secrets Manager secret name storing RDS credentials"
  value       = module.rds.rds_secret_name
}

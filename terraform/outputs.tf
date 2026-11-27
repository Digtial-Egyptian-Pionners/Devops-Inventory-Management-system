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

output "alb_dns_name" {
  description = "Public ALB DNS name for Inventory API"
  value       = module.alb.alb_dns_name
}

output "api_gateway_endpoint" {
  description = "API Gateway HTTP API endpoint for Notification Lambda"
  value       = module.lambda_apigw.api_gateway_endpoint
}

output "lambda_function_name" {
  description = "Notification Lambda function name"
  value       = module.lambda_apigw.lambda_function_name
}

output "s3_frontend_bucket_name" {
  description = "Private S3 bucket name for React SPA"
  value       = module.s3_cloudfront.s3_frontend_bucket_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.s3_cloudfront.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront HTTPS domain name"
  value       = module.s3_cloudfront.cloudfront_domain_name
}

output "ecr_repository_url" {
  description = "Amazon ECR repository URL for inventory-service"
  value       = aws_ecr_repository.inventory_service.repository_url
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "k8s_nodes_sg_id" {
  value = aws_security_group.k8s_nodes.id
}

output "lambda_sg_id" {
  value = aws_security_group.lambda.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}

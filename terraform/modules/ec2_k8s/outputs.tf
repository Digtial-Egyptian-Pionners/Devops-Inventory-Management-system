output "k8s_master_id" {
  value = aws_instance.k8s_master.id
}

output "k8s_master_private_ip" {
  value = aws_instance.k8s_master.private_ip
}

output "k8s_worker_ids" {
  value = aws_instance.k8s_worker[*].id
}

output "k8s_worker_private_ips" {
  value = aws_instance.k8s_worker[*].private_ip
}

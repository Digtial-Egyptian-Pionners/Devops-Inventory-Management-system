output "bastion_id" {
  value = aws_instance.bastion.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}

output "bastion_network_interface_id" {
  value = aws_instance.bastion.primary_network_interface_id
}

resource "aws_instance" "k8s_master" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = [var.security_group_id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 15
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-k8s-master"
    Role        = "k8s-master"
    Environment = var.environment
  }
}

resource "aws_instance" "k8s_worker" {
  count                  = var.worker_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [var.security_group_id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 15
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-k8s-worker-${count.index + 1}"
    Role        = "k8s-worker"
    Environment = var.environment
  }
}

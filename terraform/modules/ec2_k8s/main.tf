data "aws_iam_policy_document" "k8s_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "k8s_node" {
  name               = "${var.project_name}-${var.environment}-k8s-node-role"
  assume_role_policy = data.aws_iam_policy_document.k8s_assume.json
}

data "aws_iam_policy_document" "k8s_node_policy" {
  statement {
    sid       = "InvokeNotificationLambda"
    actions   = ["lambda:InvokeFunction"]
    resources = ["arn:aws:lambda:*:*:function:${var.project_name}*"]
  }

  statement {
    sid = "PullEcrImages"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "k8s_node" {
  name   = "${var.project_name}-${var.environment}-k8s-node-policy"
  role   = aws_iam_role.k8s_node.id
  policy = data.aws_iam_policy_document.k8s_node_policy.json
}

resource "aws_iam_instance_profile" "k8s_node" {
  name = "${var.project_name}-${var.environment}-k8s-node-profile"
  role = aws_iam_role.k8s_node.name
}

resource "aws_instance" "k8s_master" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.k8s_node.name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 11
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
  iam_instance_profile   = aws_iam_instance_profile.k8s_node.name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 11
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-k8s-worker-${count.index + 1}"
    Role        = "k8s-worker"
    Environment = var.environment
  }
}

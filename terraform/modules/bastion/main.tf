data "aws_iam_policy_document" "bastion_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bastion" {
  name               = "${var.project_name}-${var.environment}-bastion-role"
  assume_role_policy = data.aws_iam_policy_document.bastion_assume.json
}

data "aws_iam_policy_document" "bastion_policy" {
  statement {
    sid       = "ReadRdsSecrets"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = ["arn:aws:secretsmanager:*:*:secret:${var.project_name}/*"]
  }

  statement {
    sid       = "AnsibleDynamicInventory"
    actions   = ["ec2:DescribeInstances", "ec2:DescribeTags", "ec2:DescribeRegions"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "bastion" {
  name   = "${var.project_name}-${var.environment}-bastion-policy"
  role   = aws_iam_role.bastion.id
  policy = data.aws_iam_policy_document.bastion_policy.json
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project_name}-${var.environment}-bastion-profile"
  role = aws_iam_role.bastion.name
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  associate_public_ip_address = true
  source_dest_check           = false

  user_data = <<-EOF
              #!/bin/bash
              set -euo pipefail
              export DEBIAN_FRONTEND=noninteractive
              # Enable IP forwarding & NAT masquerade for private app subnets (Free-Tier NAT)
              sysctl -w net.ipv4.ip_forward=1
              echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
              IFACE=$(ip route show default | awk '/default/ {print $5}')
              iptables -t nat -A POSTROUTING -o "$IFACE" -j MASQUERADE

              apt-get update -y
              apt-get install -y postgresql-client netcat-openbsd jq unzip curl iptables-persistent
              curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
              unzip -q /tmp/awscliv2.zip -d /tmp
              /tmp/aws/install
              rm -rf /tmp/aws /tmp/awscliv2.zip
              EOF

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-bastion"
    Role        = "bastion"
    Environment = var.environment
  }
}

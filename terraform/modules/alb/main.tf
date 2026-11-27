resource "aws_lb" "this" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "k8s_ingress" {
  name     = "${var.project_name}-${var.environment}-k8s-tg"
  port     = var.node_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/actuator/health"
    port                = tostring(var.node_port)
    protocol            = "HTTP"
    matcher             = "200-404"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-k8s-tg"
    Environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "workers" {
  count            = length(var.target_instance_ids)
  target_group_arn = aws_lb_target_group.k8s_ingress.arn
  target_id        = var.target_instance_ids[count.index]
  port             = var.node_port
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_ingress.arn
  }
}

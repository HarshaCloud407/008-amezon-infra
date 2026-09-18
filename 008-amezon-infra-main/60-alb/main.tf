resource "aws_security_group" "ingress_alb" {
  name        = "${local.resource_name}-ingress-alb-sg"
  description = "Security group for the internet-facing ingress ALB"
  vpc_id      = local.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    var.ingress_alb_tags,
    { Name = "${local.resource_name}-ingress-alb-sg" }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ssm_parameter" "ingress_alb_sg_id" {
  name  = "/roboshop/${var.environment}/ingress_alb_sg_id"
  type  = "String"
  value = aws_security_group.ingress_alb.id

  overwrite = true

  tags = merge(
    var.common_tags,
    var.ingress_alb_tags
  )
}

module "ingress_alb" {
  source = "terraform-aws-modules/alb/aws"

  internal                   = false
  name                       = "${local.resource_name}-ingress-alb"
  vpc_id                     = local.vpc_id
  subnets                    = local.public_subnet_ids
  security_groups            = [aws_security_group.ingress_alb.id]
  create_security_group      = false
  enable_deletion_protection = false

  tags = merge(
    var.common_tags,
    var.ingress_alb_tags
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.ingress_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from Application ALB</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = module.ingress_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.https_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from Web ALB HTTPS</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "roboshop" {
  zone_id = "Z00916842MCDX0S5FWPWY"
  name    = "roboshop-${var.environment}.${var.zone_name}"
  type    = "A"

  alias {
    name                   = module.ingress_alb.dns_name
    zone_id                = module.ingress_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_target_group" "roboshop" {
  name        = local.resource_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    matcher             = "200-299"
    path                = "/"
    port                = 8080
    protocol            = "HTTP"
    timeout             = 4
  }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.roboshop.arn
  }

  condition {
    host_header {
      values = ["roboshop-${var.environment}.${var.zone_name}"]
    }
  }
}
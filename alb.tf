# Application Load balancer

resource "aws_lb" "console" {
  name                       = upper("${data.aws_iam_account_alias.current.account_alias}-console-alb")
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb_sg_console.id]
  subnets                    = [for k, v in local.main_subnets.public : v.id]
  enable_deletion_protection = true

# Enabling access log for the load balancer and saves in s3 bucket

  access_logs {
    bucket  = aws_s3_bucket.access_logging.bucket
    prefix  = lower("${data.aws_iam_account_alias.current.account_alias}-console-alb")
    enabled = true
  }

  tags = {
    Name       = "main_alb_console"
    PDU        = "Mobile Devices"
    Deployment = "Terraform"
    Workspace  = terraform.workspace
  }
}

# Target group to be attached to the load balancer

resource "aws_lb_target_group" "console" {
  name     = upper("${data.aws_iam_account_alias.current.account_alias}-console-tg")
  port     = 443
  protocol = "HTTP"
  vpc_id   = local.vpc.main.id
}

# Backend Listener ( Recieve traffic from Load balancer to EC2 instance)

resource "aws_lb_target_group_attachment" "console" {
  target_group_arn = aws_lb_target_group.console.arn
  target_id        = module.console_services.id
  port             = 443
}

# Frontend Listener ( Recieve traffic from outside/inside the organiztion to Load balancer)

resource "aws_lb_listener" "console" {
  load_balancer_arn = aws_lb.console.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "" # Yet to be filled after certificate created & uploaded to AWS ACM

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.console.arn
  }
}

# Listener certificate for https ( certificate for SSL offloading)

resource "aws_lb_listener_certificate" "console" {
  listener_arn    = aws_lb_listener.console.arn
  certificate_arn = "" # Yet to be filled after certificate created & uploaded to AWS ACM
}

# Listenert rules to forward the traffic to the target group

resource "aws_lb_listener_rule" "console" {
  listener_arn = aws_lb_listener.console.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.console.arn
  }

# Enabling host based/ path based routing

  condition {
    host_header {
      values = [""] # Yet to be filled
    }
  }
}
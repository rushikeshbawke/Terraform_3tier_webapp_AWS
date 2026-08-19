# --------External ALB - web tier ------

resource "aws_lb" "external" {
  name               = "${var.project_name}-external-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_external.id]
  subnets            = aws_subnet.public[*].id

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "external-alb-logs" # tells AWS to store ALB access logs in the S3 bucket under the path starting with external-alb-access-logs/
    enabled = true                # Tells AWS to turn on server access logging for the bucket.
  }

  tags = {
    Name = "${var.project_name}-external-alb"
  }
}

resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-external-alb-tg"
  port     = var.web_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health" # The destination for the health check request. This is the ping path that is the destination on the targets for the health check request.
    interval            = 30        # The approximate amount of time, in seconds, between health checks of an individual target.
    timeout             = 5         # The amount of time, in seconds, during which no response means a failed health check.
    healthy_threshold   = 2         # Number of consecutive successes
    unhealthy_threshold = 3         # Number of consecutive failures
    matcher             = "200-399" # The HTTP status code to use when checking for a successful response from a target.
  }

  tags = {
    Name = "${var.project_name}-external-alb-tg"
  }
}

resource "aws_lb_listener" "external_alb_listener" {
  load_balancer_arn = aws_lb.external.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# ----- Internal ALB - Application tier -----

resource "aws_lb" "internal" {
  name               = "${var.project_name}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_internal.id]
  subnets            = aws_subnet.app[*].id

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "internal-alb-logs" # tells AWS to store ALB access logs in the S3 bucket under the path starting with internal-alb-access-logs/
    enabled = true                # Tells AWS to turn on server access logging for the bucket.
  }
  tags = {
    Name = "${var.project_name}-alb-internal"
  }

}

resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-internal-alb-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health" # The destination for the health check request. This is the ping path that is the destination on the targets for the health check request.
    interval            = 30        # The approximate amount of time, in seconds, between health checks of an individual target.
    timeout             = 5         # The amount of time, in seconds, during which no response means a failed health check.
    healthy_threshold   = 2         # Number of consecutive successes
    unhealthy_threshold = 3         # Number of consecutive failures
    matcher             = "200-399" # The HTTP status code to use when checking for a successful response from a target.
  }

  tags = {
    Name = "${var.project_name}-app-tg"
  }

}

resource "aws_lb_listener" "internal_alb_listener" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

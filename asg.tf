# ------- Latest Linux AMI ID -------
data "aws_ami" "latest_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
    web_ami = coalesce(var.web_ami, data.aws_ami.latest_linux.id)   # returns the first non null, non empty value from the list of arguments.
    app_ami = coalesce(var.app_ami, data.aws_ami.latest_linux.id)
}

# ------- web tier - Launch template and ASG -------

resource "aws_launch_template" "web" {
  name_prefix = "web-launch-template-"
  image_id    = local.web_ami
  instance_type = var.web_instance_type
  key_name = var.ssh_key_name != "" ? var.ssh_key_name : null

  vpc_security_group_ids = [aws_security_group.web.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.web_profile.name
  }

  # lifecycle {
  #  create_before_destroy = true
  #}

  metadata_options {
    http_tokens = "required"   # IMDSv2 only => IIMDSv2 requires a session token for every metadata request, preventing unauthorized access.
    http_endpoint = "enabled"   # Ensures the metadata service endpoint (http://169.254.169.254) is accessible from the instance.
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(<<-EOF
  
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y nginx1
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Welcome to the Web Server</h1>" > /usr/share/nginx/html/index.html
            # Reverse-proxy example: forward /api to internal ALB (app tier)
            # Configure httpd/nginx as needed to proxy to: ${aws_lb.internal.dns_name}:${var.app_port}
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "web-instance"
      Tier = "web"
    }
  }

  tags = {
    Name = "web-launch-template"
    Tier = "web"
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "web-asg"
  max_size                  = var.web_asg_max_size
  min_size                  = var.web_asg_min_size
  desired_capacity          = var.web_asg_desired_capacity
  vpc_zone_identifier       = var.public_subnet_ids
  target_group_arns         = [aws_lb_target_group.web.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300    # ASG setting that controls how long the ASG waits before starting to evaluate the health of a newly launched instance.
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "web-instance"
    propagate_at_launch = true       # Whenever this ASG launches a new EC2 instance, automatically apply this tag to that instance too.
  }

  tag {
    key                 = "Tier"
    value               = "web"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "web_scale_out" {
name = "web-scale_out"
autoscaling_group_name = aws_autoscaling_group.web.name
policy_type = "TargetTrackingScaling"
target_tracking_configuration {
predefined_metric_specification {
    predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}

resource "aws_autoscaling_policy" "web_scale_in" {
  name = "web-scale_in"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 30.0
  }
}

# ------- app tier - Launch template and ASG -------

resource "aws_launch_template" "app" {
  name_prefix = "app-launch-template-"
  image_id    = local.app_ami
  instance_type = var.app_instance_type
  key_name = var.ssh_key_name != "" ? var.ssh_key_name : null

  vpc_security_group_ids = [aws_security_group.app.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.app_profile.name
  }

  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Placeholder app-tier bootstrap. Replace with your app deployment
    # (e.g. pull container, install runtime, connect to RDS at ${aws_db_instance.main.address}).
    dnf install -y python3
    cat > /opt/app.py << 'PYEOF'
    from http.server import BaseHTTPRequestHandler, HTTPServer
    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"app-tier ok")
    HTTPServer(("0.0.0.0", ${var.app_port}), Handler).serve_forever()
    PYEOF
    nohup python3 /opt/app.py &
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "app-instance"
      Tier = "app"
    }
  }

  tags = {
    Name = "app-launch-template"
    Tier = "app"
  }
}

resource "aws_autoscaling_group" "app" {
  name                      = "app-asg"
  max_size                  = var.app_asg_max_size
  min_size                  = var.app_asg_min_size
  desired_capacity          = var.app_asg_desired_capacity
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "app"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "app_scale_out" {
  name = "app-scale_out"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}

resource "aws_autoscaling_policy" "app_scale_in" {
  name = "app-scale_in"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 30.0
  }
}

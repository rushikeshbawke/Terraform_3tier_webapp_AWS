#----- External ALB Security Group - internet facing(from port 80 and 443)------

resource "aws_security_group" "alb_sg" {
  name   = "alb-security-group"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all outbound traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Allow HTTP access"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow HTTPS access"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------ Web tier security group - allow traffic from ALB security group only ------

resource "aws_security_group" "web_sg" {
  name   = "web-security-group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = var.web_port
    to_port         = var.web_port
    protocol        = "tcp"
    description     = "Allow HTTP access from external ALB"
    security_groups = [aws_security_group.alb_sg.id]
  }

  dynamic "ingress" {
    for_each = var.ssh_key_name != "" ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH from Admin IP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all outbound traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-security-group"
  }
}

#------ Internal ALB Security Group - Only allow traffic from Web tier ------

resource "aws_security_group" "internal_alb_sg" {
  name   = "internal-alb-security-group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    description     = "Allow HTTP access from web tier"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all outbound traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "internal-alb-security-group"
  }
}

#------ App tier security group - allow traffic from internal ALB only ------

resource "aws_security_group" "app_sg" {
  name   = "app-security-group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    description     = "Allow HTTP access from internal ALB"
    security_groups = [aws_security_group.internal_alb_sg.id]
  }

  dynamic "ingress" {
    for_each = var.ssh_key_name != "" ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH from Admin IP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all outbound traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-security-group"
  }
}

#------ Database tier security group - allow traffic from app tier only ------

resource "aws_security_group" "db_sg" {
  name   = "db-security-group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = local.db_port
    to_port         = local.db_port
    protocol        = "tcp"
    description     = "Allow MySQL access from app tier"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all outbound traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-security-group"
  }
}

locals {
  db_port = var.db_engine == "postgres" ? 5432 : 3306
}

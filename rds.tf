resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-group"
  subnet_ids = aws_subnet.db.id

  tags = { Name = "db-subnet-group" }
}

resource "random_password" "db_password" {
  length      = 20
  special     = true
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  # Avoid characters RDS disallows in passwords
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

# Password stored securely in Secrets Manager rather than plain state exposure risk.
resource "aws_secretsmanager_secret" "db_password" {
  name = "db-password-${random_id.suffix.hex}"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

resource "aws_db_instance" "main" {
  identifier     = "db-instance"
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  availability_zone = var.availability_zone

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:30-mon:05:30"

  # deletion_protection       = true
  # skip_final_snapshot       = false
  # final_snapshot_identifier = "db-final-snapshot"

  enabled_cloudwatch_logs_exports = var.db_engine == "postgres" ? ["postgresql"] : ["error", "general", "slowquery"]

  tags = { Name = "db-primary" }
}

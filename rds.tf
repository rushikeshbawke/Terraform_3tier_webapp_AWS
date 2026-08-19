resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.db[*].id

  tags = { Name = "${var.project_name}-db-subnet-group" }
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
  name = "${var.project_name}-db-password-${random_id.suffix.hex}"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

#*********** database ***********

resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
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
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  availability_zone = var.availability_zones[0]

  backup_retention_period = 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:30-mon:05:30"

  /*
  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "db-final-snapshot"
*/

  skip_final_snapshot = true # [Certain] without this, destroy WILL fail
  # Terraform tries to take a final snapshot and
  # requires final_snapshot_identifier if this is false

  deletion_protection = false # [Certain] if true, destroy errors out immediately
  # with "cannot destroy, protection enabled"


  enabled_cloudwatch_logs_exports = var.db_engine == "postgres" ? ["postgresql"] : ["error", "general", "slowquery"]

  tags = { Name = "${var.project_name}-db-primary" }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  value = aws_subnet.app[*].id
}

output "db_subnet_ids" {
  value = aws_subnet.db[*].id
}

output "external_alb_dns_name" {
  description = "Public DNS name of the internet-facing ALB"
  value       = aws_lb.external.dns_name
}

output "internal_alb_dns_name" {
  description = "Internal DNS name of the app-tier ALB"
  value       = aws_lb.internal.dns_name
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain (only set if domain_name var is provided)"
  value       = var.domain_name != "" ? aws_cloudfront_distribution.main[0].domain_name : null
}

output "rds_endpoint" {
  description = "RDS connection endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "db_secret_arn" {
  description = "Secrets Manager ARN holding the DB password"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "sns_alerts_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "flow_logs_bucket" {
  value = aws_s3_bucket.flow_logs.bucket
}

output "cloudtrail_bucket" {
  value = aws_s3_bucket.cloudtrail_logs.bucket
}

output "app_data_bucket" {
  value = aws_s3_bucket.app_data.bucket
}
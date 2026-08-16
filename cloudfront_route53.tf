# -------- route53 hosted zone (optional - only if domain name is set) ----------

resource "aws_route53_zone" "main" {
count = var.domain_name != "" && var.create_route53_zone ? 1 : 0
name = var.domain_name
}

data "aws_route53_zone" "existing" {
count = var.domain_name != "" && var.create_route53_zone ? 1 : 0
name = var.domain_name
}

locals {
  zone_id = var.domain_name == "" ? "" : (
    var.create_route53_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.existing[0].zone_id
  )
}

# --------- Cloudfront distribution in front of external ALB ---------

resource "aws_cloudfront_distribution" "main" {
count = var.domain_name != "" ? 1 : 0
enabled = true
is_ipv6_enabled = true
comment = "Cloudfront CDN in front of external ALB"
aliases = [var.domain_name]
default_root_object = ""

  origin {
    domain_name = aws_lb.external.dns_name
    origin_id   = "external-alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "external-alb"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 60
    max_ttl     = 300
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.main[0].arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = { Name = "${var.project_name}-cloudfront" }
}
}

# -------- ACM certificate for Cloudfront ----------

resource "aws_acm_certificate" "main" {
  count             = var.domain_name != "" ? 1 : 0
  provider          = "aws"
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = var.domain_name != "" ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id = local.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# -------- Route53 A/ALIAS record -> Cloudfront ---------

resource "aws_route53_record" "app" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main[0].domain_name
    zone_id                = aws_cloudfront_distribution.main[0].hosted_zone_id
    evaluate_target_health = false
  }
}

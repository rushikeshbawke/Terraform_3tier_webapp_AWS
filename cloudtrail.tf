resource "aws_cloudtrail" "trail" {
    name                          = "app-cloudtrail"
    s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.bucket
    include_global_service_events = true
    is_multi_region_trail         = true
    enable_logging                = true
    
    event_selector {
        read_write_type           = "All"
        include_management_events = true
    
        data_resource {
        type   = "AWS::S3::Object"
        values = ["arn:aws:s3:::${aws_s3_bucket.cloudtrail_bucket.bucket}/"]
        }
    }

    depends_on = [aws_s3_bucket_policy.cloudtrail_bucket_policy]
    
    tags = {
        Name = "app-cloudtrail"
        Tier = "app"
    }
    }
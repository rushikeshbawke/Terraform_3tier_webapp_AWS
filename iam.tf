# IAM Role for EC2 instances (web + app tiers)
# Matches "IAM ROLE" icon in diagram

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "EC2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Minimal baseline: SSM (for management without SSH), CloudWatch agent metrics,
# and read/write access to the app S3 bucket.
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "app_s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.app_data.arn,
      "${aws_s3_bucket.app_data.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "app_s3_access" {
  name   = "$app-s3-access"
  role   = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.app_s3_access.json
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2-profile"
  role = aws_iam_role.ec2_role.name
}

# -------- SNS Topic => CloudWatch Alarm - User (Email) --------

resource "aws_sns_topic" "alerts" {
  name = "user-alarm-topic"
}

resource "aws_sns_topic_subscription" "user_alarm_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.user_email
}

# --------- SNS Topic => General Notifications ( from Cloudfront/app events - user) --------

resource "aws_sns_topic" "notifications" {
  name = "notifications-topic"
}

resource "aws_sns_topic_subscription" "user_notifications_email" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.user_email
}
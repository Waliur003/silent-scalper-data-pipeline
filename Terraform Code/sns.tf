//Create SNS topic named "SilentScalperAlerts"
resource "aws_sns_topic" "silent_scalper_alerts" {
  name = var.topic_name

  tags = {
    Name        = "SilentScalperAlerts"
    Environment = "Production"
  }
}


//Create SNS topic subscription to email address "waliurrahmansun003@gmail.com"
resource "aws_sns_topic_subscription" "silent_scalper_alerts_email_subscription" {
  topic_arn = aws_sns_topic.silent_scalper_alerts.arn
  protocol  = "email"
  endpoint  = var.email_address
}
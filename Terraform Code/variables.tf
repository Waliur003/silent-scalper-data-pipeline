//declare variables for aws_region
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

//declare variables for email address to receive SNS notifications
variable "topic_name" {
  description = "SNS Topic Name"
  type        = string
  default     = "SilentScalperAlerts"
}

variable "email_address" {
  description = "Email address to receive SNS notifications"
  type        = string
  default     = "waliurrahmansun003@gmail.com"
}
// IAM policy document for the Silent Scalper Orchestrator Lambda function, defining precise permissions for secure and efficient operation.
data "aws_iam_policy_document" "SilentScalperOrchestratorPolicy" {

  statement {
    sid    = "SourceStorageIngressAndPurgeAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = ["arn:aws:s3:::silent-scalper-source-data-origin/*"]
  }

  statement {
    sid    = "QuarantineVaultEgressAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::silent-scalper-quarantine-vault/*"]
  }

  statement {
    sid    = "TargetedDynamoDBTableWriteAccess"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem"
    ]
    resources = ["arn:aws:dynamodb:*:*:table/ProcessedData"]
  }

  statement {
    sid    = "TargetedSNSPublishAlertAccess"
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = ["arn:aws:sns:*:*:SilentScalperAlerts"]
  }

  statement {
    sid    = "StructuredCloudWatchLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

}


//Attach the above IAM policy document to a new IAM role named "SilentScalperLambdaExecutionRole" for the Lambda function to assume, ensuring least privilege access.
resource "aws_iam_role" "SilentScalperLambdaExecutionRole" {
  name = "SilentScalperLambdaExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "SilentScalperLambdaExecutionRole"
    Environment = "Production"
  }
}

//Attach the IAM policy document to the IAM role, creating a new IAM policy named "SilentScalperOrchestratorPolicy" and associating it with the "SilentScalperOrchestratorRole".
resource "aws_iam_policy" "SilentScalperOrchestratorPolicy" {
  name        = "SilentScalperOrchestratorPolicy"
  description = "IAM policy for Silent Scalper Orchestrator Lambda function with least privilege access"
  policy      = data.aws_iam_policy_document.SilentScalperOrchestratorPolicy.json

  tags = {
    Name        = "SilentScalperOrchestratorPolicy"
    Environment = "Production"
  }
}


//Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "SilentScalperOrchestratorRolePolicyAttachment" {
  role       = aws_iam_role.SilentScalperLambdaExecutionRole.name
  policy_arn = aws_iam_policy.SilentScalperOrchestratorPolicy.arn
}
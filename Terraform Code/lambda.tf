//Create a Lambda function named "Silent-Scalper-Orchestrator" with Runtime 3.12 and archtecure x86_64, with lambda zip file "PythonLambdaCode.zip" located in the same directory as the Terraform code, and handler "lambda_function_script.lambda_handler". The Lambda function should have an execution timeout of 15 minutes and be associated with the IAM role "SilentScalperOrchestratorRole" created in the IAM section of the Terraform code.

resource "aws_lambda_function" "Silent_Scalper_Orchestrator" {
  function_name = "Silent-Scalper-Orchestrator"
  runtime       = "python3.12"
  architectures = ["x86_64"]
  handler       = "PythonLambdaCode.lambda_handler"
  role          = aws_iam_role.SilentScalperLambdaExecutionRole.arn
  timeout       = 900

  filename      = "${path.module}/PythonLambdaCode.zip"

  # Injects remote infrastructure target variables directly into your python runtime state
  environment {
    variables = {
      DYNAMO_TABLE      = aws_dynamodb_table.processed_data.name
      QUARANTINE_BUCKET = aws_s3_bucket.silent_scalper_quarantine_vault.id
      SNS_TOPIC_ARN     = aws_sns_topic.silent_scalper_alerts.arn
    }
  }

  tags = {
    Name        = "Silent-Scalper-Orchestrator"
    Environment = "Production"
  }
}




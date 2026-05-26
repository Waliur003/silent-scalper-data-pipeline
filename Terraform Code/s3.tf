//Create S3 bucket named "silent-scalper-source-data-origin"
resource "aws_s3_bucket" "silent_scalper_source_data_origin" {
  bucket = "silent-scalper-source-data-origin"
  region = var.aws_region

  tags = {
    Name        = "silent-scalper-source-data-origin"
    Environment = "Production"
  }
}

//block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "silent_scalper_source_data_origin_public_access_block" {
  bucket = aws_s3_bucket.silent_scalper_source_data_origin.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


//-------------------------------------------------------------------------


//Create bucket a second time named "silent-scalper-quarantine-vault"
resource "aws_s3_bucket" "silent_scalper_quarantine_vault" {
  bucket = "silent-scalper-quarantine-vault"
  region = var.aws_region

  tags = {
    Name        = "silent-scalper-quarantine-vault"
    Environment = "Production"
  }
}

//block all public access to the S3 quarantine bucket
resource "aws_s3_bucket_public_access_block" "silent_scalper_quarantine_vault_public_access_block" {
  bucket = aws_s3_bucket.silent_scalper_quarantine_vault.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


//deploy an accompanying aws_lambda_permission block allowing the S3 bucket service principal to pass execute instructions onto your Lambda resource identifier
resource "aws_lambda_permission" "allow_s3_to_invoke_lambda" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.Silent_Scalper_Orchestrator.function_name
  principal     = "s3.amazonaws.com"

  # Specify the source ARN to restrict permissions to the specific S3 bucket
  source_arn    = aws_s3_bucket.silent_scalper_source_data_origin.arn
}


// Establish the event-driven notification route inside your landing zone bucket
resource "aws_s3_bucket_notification" "source_bucket_notification" {
  bucket     = aws_s3_bucket.silent_scalper_source_data_origin.id
  depends_on = [aws_lambda_permission.allow_s3_to_invoke_lambda] // Forces authorization validation first

  lambda_function {
    lambda_function_arn = aws_lambda_function.Silent_Scalper_Orchestrator.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
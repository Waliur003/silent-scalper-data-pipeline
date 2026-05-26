// Output the primary data landing zone bucket name
output "source_bucket_name" {
  value       = aws_s3_bucket.silent_scalper_source_data_origin.id
  description = "The name of the S3 source data landing zone bucket"
}

// Output the quarantine tier bucket name
output "quarantine_bucket_name" {
  value       = aws_s3_bucket.silent_scalper_quarantine_vault.id
  description = "The name of the S3 bucket used for quarantine storage"
}

// Output the metadata logging table name
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.processed_data.name
  description = "The name of the DynamoDB on-demand tracking table"
}

// Output the pipeline orchestration engine name
output "lambda_function_name" {
  value       = aws_lambda_function.Silent_Scalper_Orchestrator.function_name
  description = "The name of the serverless pipeline Lambda orchestration function"
}
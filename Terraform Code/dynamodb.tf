//Create a dayanmodb table named "ProcessedData"
resource "aws_dynamodb_table" "processed_data" {
  name           = "ProcessedData"
  billing_mode   = "ON_DEMAND"
  hash_key       = "FileID"

  attribute {
    name = "FileID"
    type = "S"
  }

  tags = {
    Name        = "ProcessedData"
    Environment = "Production"
  }
}



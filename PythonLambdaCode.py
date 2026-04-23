import json
import boto3
import os
import urllib.parse
from decimal import Decimal

# Initialize AWS clients outside the handler for better performance (Warm Starts)
s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

# Configuration - Use Environment Variables in Lambda settings for these!
DYNAMO_TABLE = os.environ.get('DYNAMO_TABLE', 'ProcessedData')
QUARANTINE_BUCKET = os.environ.get('QUARANTINE_BUCKET', 'failed-data-quarantine-01')
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN', '')

def lambda_handler(event, context):
    # 1. Get the bucket name and file name (key) from the event
    # S3 keys can have spaces/special characters, so we unquote it
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
    
    print(f"Processing file: {key} from bucket: {bucket}")

    try:
        # 2. Read the file from the Source Bucket
        response = s3.get_object(Bucket=bucket, Key=key)
        data = response['Body'].read().decode('utf-8')
        
        # --- [START OF BUSINESS LOGIC] ---
        # Logic: If file is empty or missing 'id', we treat it as a failure
        file_content = json.loads(data)
        if 'id' not in file_content:
            raise ValueError("Invalid Data: Missing 'id' field")
        # --- [END OF BUSINESS LOGIC] ---

        # 3. If processing succeeds: Save metadata to DynamoDB
        table = dynamodb.Table(DYNAMO_TABLE)
        table.put_item(
            Item={
                'FileID': str(file_content['id']),
                'FileName': key,
                'Status': 'SUCCESS',
                'Size': response['ContentLength']
            }
        )
        print(f"Successfully processed {key}")

    except Exception as e:
        print(f"Failure detected for {key}: {str(e)}")
        
        # 4. If processing fails: 
        # A. Copy the file to the Quarantine Bucket
        copy_source = {'Bucket': bucket, 'Key': key}
        s3.copy_object(
            CopySource=copy_source,
            Bucket=QUARANTINE_BUCKET,
            Key=f"failed-{key}"
        )
        
        # B. Delete it from the Source Bucket (Move operation)
        s3.delete_object(Bucket=bucket, Key=key)
        
        # C. Publish a message to the SNS Topic
        if SNS_TOPIC_ARN:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject="CRITICAL: Data Processing Failure",
                Message=f"File {key} failed processing and was moved to {QUARANTINE_BUCKET}.\nError: {str(e)}"
            )
        
        return {
            'statusCode': 500,
            'body': json.dumps(f"Failed and Quarantined: {str(e)}")
        }

    return {
        'statusCode': 200,
        'body': json.dumps("File processed successfully")
    }
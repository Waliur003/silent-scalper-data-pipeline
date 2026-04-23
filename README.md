# Cloud Engineering Project 04: The Silent Scalper  
## Automated Event-Driven Data Pipeline

## Overview
This project demonstrates the design and deployment of a resilient, event-driven data processing pipeline on AWS.

The architecture is self-healing: data is ingested through cloud storage, processed using serverless compute, and automatically routed based on success or failure. This ensures zero data loss and cost efficiency by eliminating idle infrastructure.

---

## Problem
Traditional data processing systems commonly face the following issues:

- Operational inefficiency due to idle servers waiting for incoming data  
- System instability when handling sudden traffic spikes  
- Lack of robust error handling, leading to:
  - Corrupt data entering databases  
  - Silent failures that are difficult to detect  

---

## Solution

### Zero-Idle Compute
AWS Lambda is used to ensure compute resources are only active when triggered by file uploads, eliminating idle costs.

### Automated Quarantine
Invalid or corrupt JSON files are automatically moved to a dedicated quarantine bucket for further inspection.

### Real-Time Alerts
Amazon SNS is integrated to send immediate notifications when processing failures occur.

### Stateful Metadata Tracking
Amazon DynamoDB is used to store a persistent, queryable record of successfully processed data.

---

## Tech Stack

| Category   | Service |
|------------|--------|
| Compute    | AWS Lambda (Python 3.12, Boto3) |
| Storage    | Amazon S3 (Source and Quarantine Buckets) |
| Database   | Amazon DynamoDB (NoSQL) |
| Messaging  | Amazon SNS |
| Security   | IAM (Least Privilege Roles) |

---

## Project Procedure

### 1. Serverless Metadata Repository
- Created a DynamoDB table named `ProcessedData`  
- Defined `FileID` as the partition key  
- Enabled on-demand capacity for automatic scaling  

### 2. Orchestration Logic
- Developed a Python-based AWS Lambda function  
- Implemented event parsing for S3 metadata extraction  
- Handled special characters using `urllib.parse`  
- Added validation for required schema fields such as `id`  

### 3. Automated Failure Recovery
- Implemented exception handling for syntax and logic errors  
- Used the S3 copy-and-delete pattern to move invalid files to a quarantine bucket  
- Sent detailed error notifications using SNS  

### 4. Security Configuration
- Created a custom IAM execution role  
- Applied the principle of least privilege  
- Restricted access to specific S3 buckets, DynamoDB table, and SNS topic using inline policies  

### 5. Event-Driven Trigger
- Configured S3 event notifications  
- Triggered Lambda on `s3:ObjectCreated:*` events  
- Established a fully automated pipeline with no manual intervention  

---

## Verification and Results

### Successful Ingestion
Valid JSON files were uploaded and corresponding records were created in DynamoDB.

### Quarantine Validation
Invalid files were automatically moved to the quarantine bucket and removed from the source bucket.

### Notification Delivery
SNS email alerts were successfully received with detailed error information.

---

## Architecture Diagram
(Add architecture diagram here)

---

## Verification Screenshots

### S3 Event Notification Configuration
Screenshot of the S3 bucket properties showing the Lambda trigger configuration.
<img width="1905" height="801" alt="Screenshot 1 1" src="https://github.com/user-attachments/assets/a7f30664-c168-4f94-983a-4bc13bc1e213" />
<img width="1507" height="509" alt="Screenshot 1 2" src="https://github.com/user-attachments/assets/d64b8a5b-b46d-4ae0-8984-e0efdac721b0" />
### Real-Time Failure Notification
Screenshot of the SNS email alert indicating a processing failure.
<img width="1592" height="314" alt="Screenshot 2" src="https://github.com/user-attachments/assets/4b526806-c1ff-447f-8127-f372f2d84ced" />
### IAM Policy
Screenshot of the JSON IAM policy demonstrating scoped permissions.
<img width="1902" height="862" alt="Screenshot 3" src="https://github.com/user-attachments/assets/b919af29-9cba-4504-82c8-238cddd137a3" />
### DynamoDB Records
Screenshot showing processed records with FileID and status.
<img width="1919" height="909" alt="Screenshot 4" src="https://github.com/user-attachments/assets/2b590012-3d33-41c6-bad4-8f06a496b96a" />

---

## Future Improvements

### Dead Letter Queue (DLQ)
Introduce Amazon SQS DLQ to handle failed Lambda executions and retries.

### Infrastructure as Code (IaC)
Refactor deployment using Terraform to enable automated and repeatable infrastructure provisioning.

### Monitoring Dashboard
Build a CloudWatch dashboard to visualize processing success and failure rates over time.

---

## Notes
This project reflects a production-oriented serverless architecture with emphasis on reliability, cost efficiency, observability, and fault tolerance.

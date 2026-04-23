# Cloud Engineering Project 05: The Silent Scalper (Automated Data Pipeline)

## Overview
I have architected and deployed a resilient, event-driven data processing pipeline on AWS. This project demonstrates the implementation of a self-healing architecture where data is ingested via cloud storage, processed through serverless compute, and automatically routed based on the success or failure of the operation—ensuring zero data loss and optimal cost efficiency.

## The Problem
Legacy data processing systems often suffer from two major flaws: operational waste and fragility. Maintaining servers that sit idle while waiting for data is expensive, and these same systems often crash when faced with sudden traffic spikes. Furthermore, without a robust error-handling mechanism, corrupt or invalid data can "poison" the database or lead to silent failures that are difficult for engineers to detect manually.

## The Solution

**Zero-Idle Compute:**  
I have utilized AWS Lambda to ensure that compute resources only trigger when a file is uploaded, eliminating costs associated with idle servers.

**Automated Quarantine:**  
I have implemented a "Fail-Safe" logic that automatically moves corrupt or invalid JSON files to a secondary Quarantine Bucket for manual review.

**Real-Time Alerts:**  
I have integrated Amazon SNS to provide immediate email notifications to stakeholders whenever a processing failure occurs.

**Stateful Metadata Tracking:**  
I have utilized Amazon DynamoDB to maintain a permanent, searchable record of all successfully processed assets.

## Tech Stack

**Compute:** AWS Lambda (Python 3.12 / Boto3)  
**Storage:** Amazon S3 (Source & Quarantine Tiers)  
**Database:** Amazon DynamoDB (NoSQL Metadata Store)  
**Messaging:** Amazon SNS (Simple Notification Service)  
**Security:** IAM (Least-Privilege Execution Roles)

## Project Procedure

### 1. Engineered a Serverless Metadata Repository

1. I have created an Amazon DynamoDB table named ProcessedData to track successful pipeline executions.

2. I have established FileID as the Partition Key to ensure unique indexing of every processed record.

3. I have configured the table for On-Demand Capacity, ensuring the database scales automatically with processing volume.

### 2. Developed the Orchestration Logic

1. I have written a Python-based AWS Lambda function to serve as the pipeline’s brain.

2. I have implemented event-parsing logic to extract bucket metadata and handle special characters in file names using urllib.parse.

3. I have integrated a validation layer that checks for mandatory schema fields (e.g., id) before committing data to the database.

### 3. Implemented Automated Failure Recovery

1. I have engineered an except block within the Lambda logic to handle both syntax errors and business logic failures.

2. I have utilized the S3 Copy and Delete pattern to "move" invalid files into a Quarantine Bucket, ensuring the source bucket remains clean and ready for new data.

3. I have integrated the SNS publish API to send critical failure details and error logs directly to an engineer's inbox.

### 4. Enforced Hardened Security (IAM)

1. I have configured a Custom Execution Role to adhere to the Principle of Least Privilege.

2. I have implemented a JSON-based Inline Policy that strictly limits access to specific ARNs for the S3 buckets, DynamoDB table, and SNS topic, preventing unauthorized resource manipulation.

### 5. Established the Event-Driven Trigger

1. I have finalized the automation by establishing an S3 Event Notification on the source bucket.

2. I have linked s3:ObjectCreated:* events to the Lambda function, creating a fully autonomous workflow that requires no manual start command.

## Verification and Results

**Verified Successful Ingestion:**  
I have uploaded valid JSON payloads and confirmed that a corresponding metadata record was instantly created in the DynamoDB table.

**Validated Quarantine Logic:**  
I have uploaded corrupt files (e.g., invalid_logic.json) and verified that the pipeline automatically moved the file to the Quarantine Bucket and deleted the original source.

**Confirmed Notification Delivery:**  
I have verified the receipt of SNS Email Alerts containing specific error messages for every failed processing attempt.

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

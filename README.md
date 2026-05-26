# Cloud Engineering Project 05: The Silent Scalper (Automated Data Pipeline)

## Overview

I have architected and deployed a highly resilient, event-driven data processing pipeline on AWS using Infrastructure as Code primitives. This project demonstrates a production-grade, self-healing cloud architecture that completely automates data ingestion, schema validation, exception containment, and stateful tracking. The pipeline ingests unstructured JSON data streams via cloud storage landing zones, runs real-time serverless business logic transformation, logs successfully processed transactions into an on-demand NoSQL database, and isolates malformed payloads automatically into a secure quarantine storage vault while dispatching real-time notifications to engineering stakeholders. By decoupling the storage boundary layer from zero-idle compute primitives, the architecture guarantees absolute fault tolerance and zero data loss with optimal cost efficiency.

---

## The Problem

Legacy data ingestion frameworks and batch-oriented monolithic processing architectures consistently suffer from structural fragility and operational cost inefficiencies. Naive data ingestion workflows typically exhibit two critical design flaws:

### Idle Infrastructure and High Compute Spend

Maintaining dedicated, always-on servers or container groups to poll file directories or wait for inbound data transfers scales poorly and incurs substantial idle compute costs during quiet traffic windows.

### Fragile Exception Handling and Poison Pill Ingestions

Ingesting malformed, corrupted, or schema-breaking payloads without an isolated recovery tier risks contaminating production databases or crashing downstream processing tasks. Without immediate alert visibility, engineering teams suffer from blind spots, and diagnosing silent processing failures requires manual, slow log exploration.

---

## The Solution

### Zero-Idle Serverless Compute Tier

Utilized an event-driven AWS Lambda execution worker that remains inactive until an object is physically written to the ingestion layer, reducing infrastructure idle compute costs to zero.

### Automated Quarantine Isolation Vault

Engineered a defensive fallback loop using an atomic copy-and-delete pattern to instantly isolate invalid data payloads into a separate validation bucket, keeping the main processing lane clean.

### Real-Time Asynchronous Monitoring Alerts

Integrated a decoupled pub-sub notification module to automatically broadcast detailed layer-7 operational exception payloads to stakeholders' endpoints within milliseconds of an ingestion failure.

### Dynamic On-Demand Schema Tracking

Deployed a highly available NoSQL storage schema configured for on-demand capacity, ensuring that tracking metrics scale seamlessly with data processing spikes without manual intervention.

---

## Tech Stack

### Storage & Landing Zones

- Amazon S3 (Source and Quarantine Isolation Tiers)

### Compute Tier

- AWS Lambda (Python 3.12 / Native Boto3 Serverless Runtimes)

### Database Persistence

- Amazon DynamoDB (On-Demand NoSQL Indexing)

### Messaging Systems

- Amazon SNS (Simple Notification Service / Pub-Sub Architecture)

### Identity Governance

- AWS IAM (Least-Privilege Scoped Policies and Roles)

### IaC Engine

- Terraform (v1.0+ / Version-Locked Declarative Configurations)

---

## Architecture Diagram

<img width="1169" height="827" alt="Architecture Diagram" src="https://github.com/user-attachments/assets/e3fb2cc7-324b-4080-a06e-cddfa47abc9d" />


---

# Project Procedure

## 1. Multi-Tier Storage Zone & Isolation Configuration

I engineered a segmented object storage architecture using Amazon S3 to cleanly separate unvalidated ingestion streams from quarantined processing failures.

### Ingestion Zone Provisioning

Deployed the primary ingestion bucket `silent-scalper-source-data-origin` to collect inbound operational raw files.

### Containment Tier Provisioning

Deployed the secondary bucket `silent-scalper-quarantine-vault` to serve as a secure holding vault for malformed objects.

### Perimeter Access Hardening

Configured explicit public access blocks on both buckets, turning on all key restrictions (`block_public_acls`, `block_public_policy`, `ignore_public_acls`, `restrict_public_buckets`) to guarantee absolute data insulation.

---

## 2. On-Demand Metadata Repository Engineering

I provisioned a highly scalable, schema-enforced persistence tier using Amazon DynamoDB to serve as the long-term pipeline execution logging catalog.

### Index Key Mapping

Established `FileID` as the primary string partition tracking index to guarantee unique item distribution and rapid search capabilities across logging entries.

### On-Demand Capacity Architecture

Configured the table billing framework to utilize `ON_DEMAND` allocation. This removes manual throughput planning, enabling the metadata store to scale automatically with rapid batch bursts without resource idling.

---

## 3. Alert Notification Infrastructure Deployment

I configured an asynchronous alerting pipeline using Amazon SNS to replace manual log-auditing routines with real-time pushes.

### Pub-Sub Topic Mapping

Created a Standard SNS topic named `SilentScalperAlerts` to act as the central distribution hub for diagnostic failure data.

### Subscriber Endpoint Binding

Anchored an explicit email protocol subscription mapping directly to an automated operational monitoring inbox, establishing an instant alert dispatch path for layer-7 exceptions.

---

## 4. Least-Privilege Identity Boundaries Formulation

To achieve total identity isolation for the serverless container execution context, I engineered a zero-trust security architecture using AWS IAM.

### Principal Access Separation

Formulated an IAM role specifying a trust relationship policy document that securely restricts role assumption exclusively to the `lambda.amazonaws.com` service principal.

### Granular Action Scoping

Authored a highly targeted permission document that explicitly defines permissible resource destinations by mapping individual ARNs. The policy limits actions strictly to:

- `s3:GetObject`
- `s3:DeleteObject` on the source origin
- `s3:PutObject` on the quarantine tier
- `dynamodb:PutItem` on the tracking index
- `sns:Publish` on the alert topic

---

## 5. Asynchronous Event-Driven Trigger Automation

I finalized the pipeline's end-to-end automation loops by mapping real-time cross-service interaction links at the storage boundary.

### Cross-Service Invocation Clearance

Deployed an `aws_lambda_permission` resource block that explicitly permits the `s3.amazonaws.com` principal to issue function execution arguments against the orchestrator function.

### Landing Zone Trigger Automation

Embedded an `aws_s3_bucket_notification` configuration rule targeting `s3:ObjectCreated:*` events on the source bucket. This completes the automated loop, launching the entire serverless execution sequence seamlessly without human intervention.

---

# Infrastructure as Code (IaC) Architecture

To enforce the core cloud engineering principles of repeatability, drift detection, and immutable infrastructure, the entire self-healing environment is provisioned using declarative Terraform (v1.0+) configurations. The codebase is cleanly decoupled into modular component files to separate storage, identity, database, and messaging logic domains.

---

## Directory Layout & Modular Structure

The workspace is organized using a flat, high-readability layout optimized for granular component modifications:

```text
silent-scalper-pipeline/
├── provider.tf          # Core initialization and provider package constraints
├── variables.tf         # Input variable defaults, types, and string abstractions
├── s3.tf                # Storage tiers, invocation permissions, and trigger rules
├── dynamodb.tf          # On-demand NoSQL infrastructure tables and index keys
├── sns.tf               # Notification topics and endpoint notification channels
├── iam.tf               # Trust definitions and granular least-privilege policies
├── lambda.tf            # Compute function runtimes and manual zip package mappings
└── outputs.tf           # Exposed resource attributes for validation tracking
```

---

# Detailed File-by-File Technical Breakdown

## 1. System Provider Scoping (provider.tf)

### Package Lock Enforcement

Restricts the provisioning environment to lock dependencies securely against the modern AWS Provider v5.0+ plugin ecosystem to utilize advanced resource schema controls.

### Dynamic Regional Scoping

Binds the platform provider layer directly to standard geographic input variables to maintain consistency across deployments.

---

## 2. Variable Abstractions & Metadata Outputs (variables.tf & outputs.tf)

### Environment Portability Mapping

Parameterizes target location metrics, notification strings, and alerting destinations via strongly typed string variables, keeping code portable.

### Programmatic Monitoring Outputs

Captures live deployment parameters (`source_bucket_name`, `quarantine_bucket_name`, `dynamodb_table_name`) to expose key resource tags for pipeline audits.

---

## 3. Private Storage Ingestion Tier (s3.tf)

### Multi-Tier Segmentation

Provisions the distinct source landing zone and failure vault containers as separate bucket resources.

### Automated Orchestration Linkage

Establishes the bucket notification routing loop to forward creation triggers across service boundaries, adding an explicit dependency on the Lambda permission resource to guarantee secure startup loops.

---

## 4. On-Demand Data Cataloging Index (dynamodb.tf)

### Provisionless Scalability

Enforces the required `billing_mode = "ON_DEMAND"` parameter to unlock dynamic data throughput scaling and maximize cost savings by avoiding idle capacity settings.

### Attribute Consistency

Maps the underlying structural string partition key formatting required to parse and log index tokens dynamically without table schema degradation.

---

## 5. Enterprise Notification Infrastructure (sns.tf)

### Standard Topic Allocation

Provisions the central alerting pipeline hub named `SilentScalperAlerts` from abstracted environment parameters.

### Asynchronous Link Subscriptions

Maps an explicit communication channel subscription endpoint string over to your monitoring inbox, binding the messaging layout to standard email transport parameters.

---

## 6. Identity Governance Control Framework (iam.tf)

### Secure Token Handshakes

Sets up an atomic role profile container and attaches it to an active trust contract allowing serverless execution contexts to assume operational identities.

### Scoped Capability Maps

Compiles layer-7 permissions via an inline configuration, isolating allow metrics to explicit target ARNs to eliminate wildcard security risks.

---

## 7. Serverless Compute Configuration (lambda.tf)

### Isolated Compute Execution

Configures an `aws_lambda_function` tracking an immutable Python runtime deployed over an advanced `x86_64` system block architecture.

### Decoupled Variables Environment

Embeds a dedicated environment block to inject DynamoDB tables, quarantine targets, and SNS ARNs directly into your script variables upon runtime creation. This architecture completely decouples infrastructure data from baseline application code logic.

---

# Verification and Results

## Verified Successful Payload Ingestion

Uploaded a completely valid, schema-compliant JSON file containing all required lookup parameters into the secure source bucket landing zone. Logging telemetry inside Amazon CloudWatch confirmed that the S3 layer successfully broadcasted the creation notice, while the Lambda function executed flawlessly, returning an HTTP 200 code and committing a valid status row into the ProcessedData table.

---

## Validated Isolated Quarantine Logic

Injected a corrupted data payload missing mandatory internal application validation fields into the ingestion bucket lane. System logs verified that the Lambda orchestrator successfully intercepted the processing anomaly via its catch-all exception framework, blocked entry to the production database, copied the bad file to the `silent-scalper-quarantine-vault` container, and purged the original file from the input queue.

---

## Confirmed Asynchronous Alert Delivery

Inspected the monitoring engineering mailbox following the corrupted asset file injection test runs. I verified absolute communication success, noting that the pub-sub notification module automatically compiled and delivered a comprehensive, formatted diagnostic alert detailing the exact file name, bucket origin, and layer-7 API exception trace.

---

# Verification Screenshots

## S3 Event Notification Configuration

Screenshot of the Amazon S3 source bucket properties portal displaying an active, verified event trigger mapping all object creation events straight into the Lambda orchestrator function ARN.

<img width="1905" height="801" alt="Screenshot 1 1" src="https://github.com/user-attachments/assets/b832cc05-da65-4731-bb4a-9db6e872e396" />
<img width="1507" height="509" alt="Screenshot 1 2" src="https://github.com/user-attachments/assets/5d01d981-9d78-4820-b36f-78a4f6ba75e8" />



---

## Real-Time Failure Notification

Screenshot of an engineering email inbox showcasing the successful arrival of a critical, automated alert notification containing a detailed stack trace of a failed payload run.

<img width="1592" height="314" alt="Screenshot 2" src="https://github.com/user-attachments/assets/787d119b-ab64-4c50-83f7-150e26fef8ac" />


---

## IAM Policy

Screenshot of the AWS IAM console showing the custom least-privilege JSON security policy layout, verifying targeted ARN limitations across S3, DynamoDB, and SNS platforms.

<img width="1902" height="862" alt="Screenshot 3" src="https://github.com/user-attachments/assets/bc71a71b-9f53-47fe-b24d-eaadb0177cd8" />


---

## DynamoDB Records

Screenshot of the Amazon DynamoDB item explorer interface viewing active entries inside the tracking table, verifying successful storage of processed object ids, file sizes, and transaction timestamps.

<img width="1919" height="909" alt="Screenshot 4" src="https://github.com/user-attachments/assets/69e7abfb-16a4-44b1-9914-15f599e8ea51" />


---

# Future Improvements

### Dead Letter Queue (DLQ) Resilience Integration

Incorporate an alternate Amazon SQS (Simple Queue Service) Dead Letter Queue array into the Lambda error routing rules to intercept and buffer un-executable container invocation attempts automatically.

### Centralized Operational Observability Dashboard

Build a consolidated Amazon CloudWatch Dashboard containing real-time widgets to visualize pipeline performance trends, tracking successful vs. quarantined ingestion metrics.

### Continuous Integration State Testing (CI/CD)

Deploy a continuous delivery pipeline utilizing GitHub Actions to automate infrastructure testing using security scanning tools like tflint and checkov before rolling out infrastructure state changes.

---

# Notes

This architecture highlights an optimized serverless design pattern for building highly resilient, fault-tolerant enterprise ingestion engines. It showcases specialized cloud core competencies in structuring edge storage event routers, programmatic data mutation, zero-trust resource isolation boundaries, and repeatable infrastructure-as-code automation workflows.

---


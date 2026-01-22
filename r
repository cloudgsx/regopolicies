Summary: What Our OPA Policy Does
Purpose
Prevents accidental SNS topic policy overwrites when configuring S3 bucket notifications.

How It Works
Input: Terraform plan JSON (from terraform show -json plan.tfplan)
Process:

Scans the plan for aws_s3_bucket_notification and aws_sns_topic_policy resources
Extracts SNS topic ARNs from those resources
Checks: Is that same SNS topic being created (aws_sns_topic) in this plan?

Matches by ARN (if available)
Falls back to matching by topic name (if ARN is computed)
Checks both root-level resources AND nested module resources



Output:

⚠️ WARNING if topic is NOT in the plan (assumes it already exists)
✅ Silent if topic IS in the plan (safe - everything is new)


What It Detects
Warning Scenario 1: S3 notification to existing topic
Plan contains: aws_s3_bucket_notification → points to "arn:aws:sns:...:existing-topic"
Plan does NOT contain: aws_sns_topic with that ARN
Result: ⚠️ WARN - "This can overwrite the topic policy"
Warning Scenario 2: SNS policy update on existing topic
Plan contains: aws_sns_topic_policy (action: update/replace)
Plan does NOT contain: aws_sns_topic for that ARN
Result: ⚠️ WARN - "Verify existing statements aren't lost"
Safe Scenario: Both created together
Plan contains: aws_sns_topic (name: "my-topic")
Plan contains: aws_s3_bucket_notification → points to that topic
Result: ✅ Silent - No risk, everything is new

What It Does NOT Do
❌ Does NOT connect to AWS to check what exists
❌ Does NOT read Terraform state files
❌ Does NOT block the Terraform apply (just warns)
❌ Does NOT know about topics in other Terraform repos/workspaces

Key Features
✅ Module-aware - Finds resources in nested Terraform modules
✅ Configuration-driven skip logic - Can whitelist certain resources via opa_exceptions
✅ Debug logging - Detailed trace output for troubleshooting
✅ Handles computed values - Works even when ARNs are "known after apply"

In Simple Terms
"If you're hooking up S3 notifications to an SNS topic that you're not creating in this same Terraform run, we warn you because the S3 module might accidentally overwrite that topic's policy and break other integrations."

Why This Matters
When Terraform creates an S3 bucket notification to an existing SNS topic, the AWS provider often replaces the entire topic policy instead of appending to it. This can delete statements needed by other services, breaking their access to the topic.
This policy catches that pattern and says: "Hey, double-check this won't break anything!"

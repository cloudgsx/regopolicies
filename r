package policies.s3_sns_existing_topic_warn

# This module returns warnings (does not fail).
# Usage: opa eval -f pretty -d policy -i plan.json 'data.policies.s3_sns_existing_topic_warn.warnings'

default warnings := []

# Warn when S3 bucket notifications target an existing SNS topic
warnings[w] {
  rc := input.resource_changes[_]
  rc.type == "aws_s3_bucket_notification"
  
  after := rc.change.after
  after != null
  
  # Check all topic configurations
  topics := object.get(after, "topic", [])
  some t
  topic := topics[t]
  topic_arn := object.get(topic, "topic_arn", "")
  
  # Topic ARN exists (could be literal ARN, variable reference, or computed)
  is_string(topic_arn)
  topic_arn != ""
  
  # The SNS topic is NOT being created in this same plan
  not topic_is_created_in_plan(topic_arn)
  
  w := {
    "severity": "WARNING",
    "rule": "s3-notification-existing-sns-topic",
    "resource_address": rc.address,
    "sns_topic_arn": topic_arn,
    "message": sprintf(
      "S3 bucket notification (%s) publishes to an existing SNS topic (%s). This pattern can overwrite the SNS topic policy. Validate the final topic policy and run an end-to-end notification test.",
      [rc.address, topic_arn]
    )
  }
}

# Warn when SNS topic policy is being updated/replaced for an existing topic
warnings[w] {
  rc := input.resource_changes[_]
  rc.type == "aws_sns_topic_policy"
  
  # Policy is being updated or replaced (not created fresh)
  actions := rc.change.actions
  updates_or_replaces(actions)
  
  after := rc.change.after
  after != null
  topic_arn := object.get(after, "arn", "")
  
  # Topic is NOT being created in this plan
  not topic_is_created_in_plan(topic_arn)
  
  w := {
    "severity": "WARNING",
    "rule": "sns-topic-policy-overwrite-risk",
    "resource_address": rc.address,
    "sns_topic_arn": topic_arn,
    "message": sprintf(
      "SNS topic policy (%s) for topic %s is being updated/replaced. Verify existing policy statements aren't being lost.",
      [rc.address, topic_arn]
    )
  }
}

# ---- Helper Functions ----

# Check if an SNS topic is being created in this plan
topic_is_created_in_plan(topic_arn) {
  some i
  sns_rc := input.resource_changes[i]
  sns_rc.type == "aws_sns_topic"
  creates(sns_rc.change.actions)
  
  after := sns_rc.change.after
  after != null
  
  # Try to match by ARN (if it's resolved)
  created_arn := object.get(after, "arn", "")
  is_string(created_arn)
  created_arn == topic_arn
}

topic_is_created_in_plan(topic_arn) {
  # Fallback: match by topic name when ARN is not yet computed
  # Extract topic name from ARN: arn:aws:sns:region:account:topic-name
  contains(topic_arn, "arn:aws:sns:")
  parts := split(topic_arn, ":")
  count(parts) >= 6
  topic_name := parts[5]
  
  some i
  sns_rc := input.resource_changes[i]
  sns_rc.type == "aws_sns_topic"
  creates(sns_rc.change.actions)
  
  after := sns_rc.change.after
  after != null
  created_name := object.get(after, "name", "")
  created_name == topic_name
}

creates(actions) {
  actions[_] == "create"
}

updates_or_replaces(actions) {
  actions[_] == "update"
}

updates_or_replaces(actions) {
  actions[_] == "replace"
}




OPA Policy Logic Summary
Goal: Detect when Terraform changes might accidentally overwrite an SNS topic policy, and warn engineers before they apply.

Two warning triggers:
1. S3 bucket notifications → existing SNS topic

Looks for aws_s3_bucket_notification resources in the plan
Checks if they reference an SNS topic ARN
Key check: Is that SNS topic being created in this same plan?

If NO → it's an existing topic → WARN
If YES → it's new, so no risk → silent



2. SNS topic policy updates on existing topics

Looks for aws_sns_topic_policy resources being updated/replaced
Checks if the topic itself is being created in this plan

If NO → updating policy on existing topic → WARN
If YES → new topic, policy is fresh → silent




How it figures out "existing" vs "new":
The policy checks if an aws_sns_topic resource with a matching ARN or name is in the plan with action "create".

First try: Match by ARN (if the ARN is already resolved in the plan JSON)
Fallback: Extract the topic name from the ARN and match by name (handles cases where ARN is "(known after apply)")

If no match found → topic is "existing" → trigger warning.

Output:
Structured warning objects with:

Resource address (which S3 bucket or policy resource)
SNS topic ARN
Human-readable message explaining the risk

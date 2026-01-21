 cat s3_sns_existing_topic_warn.rego
package policies.s3_sns_existing_topic_warn

# This module returns warnings (does not fail).
# Usage: opa eval -f pretty -d policy -i plan.json 'data.policies.s3_sns_existing_topic_warn.warnings'

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

=======================

root@roberto-H610M-H-V3-DDR4:/data/opatest# cat s3_sns_existing_topic_warn_test.rego 
package policies.s3_sns_existing_topic_warn

import future.keywords.in

# Test: S3 notification to EXISTING SNS topic → should WARN
test_s3_notification_existing_topic_warns {
  plan := {
    "resource_changes": [
      {
        "address": "aws_s3_bucket_notification.bucket_notify",
        "type": "aws_s3_bucket_notification",
        "change": {
          "actions": ["create"],
          "after": {
            "bucket": "my-new-bucket",
            "topic": [
              {
                "topic_arn": "arn:aws:sns:eu-west-1:123456789012:existing-topic"
              }
            ]
          }
        }
      }
    ]
  }
  
  result := warnings with input as plan
  count(result) == 1
  some w in result
  w.rule == "s3-notification-existing-sns-topic"
  w.sns_topic_arn == "arn:aws:sns:eu-west-1:123456789012:existing-topic"
}

# Test: S3 notification to NEW SNS topic (created in same plan) → should NOT warn
test_s3_notification_new_topic_no_warning {
  plan := {
    "resource_changes": [
      {
        "address": "aws_sns_topic.new_topic",
        "type": "aws_sns_topic",
        "change": {
          "actions": ["create"],
          "after": {
            "name": "my-new-topic",
            "arn": "arn:aws:sns:eu-west-1:123456789012:my-new-topic"
          }
        }
      },
      {
        "address": "aws_s3_bucket_notification.bucket_notify",
        "type": "aws_s3_bucket_notification",
        "change": {
          "actions": ["create"],
          "after": {
            "bucket": "my-new-bucket",
            "topic": [
              {
                "topic_arn": "arn:aws:sns:eu-west-1:123456789012:my-new-topic"
              }
            ]
          }
        }
      }
    ]
  }
  
  result := warnings with input as plan
  count(result) == 0
}

# Test: S3 notification with computed ARN (known after apply) → should WARN
test_s3_notification_computed_arn_warns {
  plan := {
    "resource_changes": [
      {
        "address": "aws_s3_bucket_notification.bucket_notify",
        "type": "aws_s3_bucket_notification",
        "change": {
          "actions": ["create"],
          "after": {
            "bucket": "my-new-bucket",
            "topic": [
              {
                "topic_arn": "(known after apply)"
              }
            ]
          }
        }
      }
    ]
  }
  
  result := warnings with input as plan
  count(result) == 1
}

# Test: SNS topic policy UPDATE on existing topic → should WARN
test_sns_policy_update_existing_topic_warns {
  plan := {
    "resource_changes": [
      {
        "address": "aws_sns_topic_policy.topic_policy",
        "type": "aws_sns_topic_policy",
        "change": {
          "actions": ["update"],
          "after": {
            "arn": "arn:aws:sns:eu-west-1:123456789012:existing-topic",
            "policy": "{\"Version\":\"2012-10-17\",\"Statement\":[...]}"
          }
        }
      }
    ]
  }
  
  result := warnings with input as plan
  count(result) == 1
  some w in result
  w.rule == "sns-topic-policy-overwrite-risk"
}

# Test: SNS topic policy on NEW topic → should NOT warn
test_sns_policy_new_topic_no_warning {
  plan := {
    "resource_changes": [
      {
        "address": "aws_sns_topic.new_topic",
        "type": "aws_sns_topic",
        "change": {
          "actions": ["create"],
          "after": {
            "name": "my-new-topic",
            "arn": "arn:aws:sns:eu-west-1:123456789012:my-new-topic"
          }
        }
      },
      {
        "address": "aws_sns_topic_policy.topic_policy",
        "type": "aws_sns_topic_policy",
        "change": {
          "actions": ["create"],
          "after": {
            "arn": "arn:aws:sns:eu-west-1:123456789012:my-new-topic",
            "policy": "{\"Version\":\"2012-10-17\",\"Statement\":[...]}"
          }
        }
      }
    ]
  }
  
  result := warnings with input as plan
  count(result) == 0
}

# Test: Name-based matching when ARN is not computed yet
test_name_based_matching_works {
  plan := {
    "resource_changes": [
      {
        "address": "aws_sns_topic.new_topic",
        "type": "aws_sns_topic",
        "change": {
          "actions": ["create"],
          "after": {
            "name": "my-new-topic",
            "arn": null
          }
        }
      },
      {
        "address": "aws_s3_bucket_notification.bucket_notify",
        "type": "aws_s3_bucket_notification",
        "change": {
          "actions": ["create"],
          "after": {
            "bucket": "my-new-bucket",
            "topic": [
              {
                "topic_arn": "arn:aws:sns:eu-west-1:123456789012:my-new-topic"
              }
            ]
          }
        }
      }
    ]
  }
  
  result := warnings with input as plan
  count(result) == 0
}

# Test: No S3 notifications at all → should not warn
test_no_resources_no_warnings {
  plan := {
    "resource_changes": []
  }
  
  result := warnings with input as plan
  count(result) == 0
}

# Test: INTENTIONAL FAILURE - this test should fail to demonstrate test failure output
test_intentional_failure_demo {
  plan := {
    "resource_changes": [
      {
        "address": "aws_s3_bucket_notification.bucket_notify",
        "type": "aws_s3_bucket_notification",
        "change": {
          "actions": ["create"],
          "after": {
            "bucket": "my-new-bucket",
            "topic": [
              {
                "topic_arn": "arn:aws:sns:eu-west-1:123456789012:existing-topic"
              }
            ]
          }
        }
      }
    ]
  }
  
  result := warnings with input as plan
  
  # This assertion is WRONG on purpose - we expect 1 warning, but we're asserting 0
  count(result) == 0  # ← This will FAIL because result actually has 1 warning
  
  # This will also fail - wrong rule name
  some w in result
  w.rule == "some-nonexistent-rule"  # ← This doesn't exist
}

============

Test Summary for ECPAWS-3316
OPA Policy Tests (Unit Tests)
All 7 tests passing ✅

S3 notification to existing SNS topic → Policy correctly warns
S3 notification to new SNS topic (created in same plan) → Policy correctly stays silent (no false positive)
S3 notification with computed ARN (known after apply) → Policy correctly warns (safe default)
SNS topic policy update on existing topic → Policy correctly warns
SNS topic policy on new topic (created in same plan) → Policy correctly stays silent (no false positive)
Name-based matching fallback (when ARN not computed yet) → Policy correctly identifies new topic and stays silent
Empty plan (no S3 notifications) → Policy correctly stays silent

Test Command:
bashopa test . -v
Result: PASS: 7/7
Coverage:

✅ Detects risky S3→SNS notification patterns
✅ Detects SNS policy overwrites on existing topics
✅ No false positives when topic is created in same plan
✅ Handles computed/unknown ARNs safely (warns by default)
✅ Name-based fallback matching works correctly

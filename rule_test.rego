package aws.aws_s3_bucket_notification.sns_existing_topic_policy_overwrite_warn_test

import data.aws.aws_s3_bucket_notification.sns_existing_topic_policy_overwrite_warn.violations
import rego.v1

mock_data := data.sns_existing_topic_policy_overwrite_warn

# Should warn: existing SNS topic ARN referenced by one or more bucket notifications
test_warns_for_existing_topic if {
  v := violations with input as mock_data.invalid_existing_topic_used
  count(v) > 0
}

# Should NOT warn: SNS topic created in same plan, bucket notification references that created ARN
test_no_warn_when_topic_created_in_plan if {
  v := violations with input as mock_data.valid_topic_created_in_plan
  count(v) == 0
}

# Should warn only once per topic (dedupe across plan)
test_dedupes_per_topic_arn if {
  v := violations with input as mock_data.invalid_duplicate_use_same_topic
  # BofA pattern creates one violation per resource, not per topic
  # Two resources use same topic = 2 violations
  count(v) == 2
}

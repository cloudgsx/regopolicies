package aws.aws_sns_topic.unique_name_check_test

import data.aws.aws_sns_topic.unique_name_check.violations
import rego.v1

mock_data := data.sns_topic_unique_name_check

# Should flag duplicate topic names
test_flags_duplicate_names if {
  v := violations with input as mock_data.invalid_duplicate_names
  count(v) > 0
}

# Should NOT flag when all names are unique
test_allows_unique_names if {
  v := violations with input as mock_data.valid_unique_names
  count(v) == 0
}

# Should create only ONE violation per duplicate resource
test_one_violation_per_duplicate_name if {
  v := violations with input as mock_data.invalid_three_duplicates
  # BofA pattern creates one violation per resource
  # 3 resources with same name = 3 violations
  count(v) == 3
}

# Should handle multiple different duplicate names
test_multiple_duplicate_names if {
  v := violations with input as mock_data.invalid_multiple_duplicate_sets
  # BofA pattern: 2 "prod-topic" resources + 2 "dev-topic" resources = 4 violations total
  count(v) == 4
}

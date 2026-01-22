**Enhanced OPA Policy (matches your org's framework):**
- ✅ Module traversal for nested resources
- ✅ Configuration-driven skip logic (`opa_exceptions`)
- ✅ Debug logging throughout
- ✅ Provider account filtering
- ✅ Regex pattern matching for exceptions
- ✅ Proper package structure (`terraform.module`)

**Test Coverage:**
1. S3 notification to existing topic → warns ✅
2. S3 notification to new topic → silent ✅
3. Skip logic prevents warning when configured ✅
4. SNS policy update on existing topic → warns ✅
5. Name-based matching fallback works ✅
6. No resources → no warnings ✅
=====


cat s3_sns_existing_topic_warn.rego
# This sample provides defensive checks for S3 bucket notifications
# that target existing SNS topics, which can cause policy overwrites.
# ECPAWS-3316: Defensive Code to prevent inadvertent Policy overwrites

package terraform.module

import data.utils
import future.keywords.contains
import future.keywords.if
import future.keywords.in

#############################################################
# Policy Configuration
#############################################################

policy_title := "s3-sns-notification-warning"

#############################################################
# Main Warning Output
#############################################################

outputs contains value if {
    input_plan := get_plan
    value := input_plan.planned_values.outputs
}

#############################################################
# Core Warning Logic
#############################################################

# Returns list of warnings for S3 notifications to existing SNS topics
warnings := result if {
    utils.debug("into s3_sns_existing_topic_warn.warnings")
    
    input_plan := get_plan
    provider_account_number := get_provider_account_number
    
    # Get resources from both resource_changes and modules
    resource_changes_resources := get_resource_changes_resources(input_plan, provider_account_number)
    module_resources := get_module_resources(input_plan, provider_account_number)
    
    all_resources := array.concat(resource_changes_resources, module_resources)
    
    utils.debug_sprintf("s3_sns_warn: found %d total resources to check", [count(all_resources)])
    
    # Check each resource for S3→SNS notification patterns
    warnings_list := [w |
        some resource in all_resources
        
        opa_skip := is_opa_skip(resource, policy_title, provider_account_number)
        utils.debug_sprintf("s3_sns_warn: checking %s, skip=%s", [resource.address, opa_skip])
        
        not opa_skip
        
        # Check for S3 bucket notifications
        warning := check_s3_notification_warning(resource, input_plan)
        w := warning
    ]
    
    # Also check for SNS policy updates
    policy_warnings_list := [w |
        some resource in all_resources
        
        opa_skip := is_opa_skip(resource, policy_title, provider_account_number)
        not opa_skip
        
        warning := check_sns_policy_warning(resource, input_plan)
        w := warning
    ]
    
    all_warnings := array.concat(warnings_list, policy_warnings_list)
    
    result := all_warnings
} else := result if {
    result := []
}

#############################################################
# Resource Collection Functions
#############################################################

# Get resources from resource_changes (root level)
get_resource_changes_resources(input_plan, provider_account_number) := resources if {
    utils.debug("into get_resource_changes_resources")
    
    resources := [x |
        some resource in input_plan.resource_changes
        
        # Only check S3 notifications and SNS policies
        resource.type in ["aws_s3_bucket_notification", "aws_sns_topic_policy", "aws_sns_topic"]
        
        resource.mode == "managed"
        
        opa_skip := is_opa_skip(resource, policy_title, provider_account_number)
        utils.debug_sprintf("resource_changes: %s, skip=%s", [resource.address, opa_skip])
        
        not opa_skip
        
        x := resource
    ]
} else := resources if {
    resources := []
}

# Get resources from modules (nested resources)
get_module_resources(input_plan, provider_account_number) := resources if {
    utils.debug("into get_module_resources")
    
    modules := get_modules
    
    module_resource_list := [x2 |
        some module
        module = modules[_]
        
        some resource
        resource = module.value.resources[_]
        
        resource.type in ["aws_s3_bucket_notification", "aws_sns_topic_policy", "aws_sns_topic"]
        
        resource.mode == "managed"
        
        # Build full resource path
        dot_path := concat(".", module.path)
        new_json := {x: y |
            resource[x]
            y := replace_value(x, "address", concat(".", [dot_path, resource.address]), resource[x])
        }
        
        opa_skip := is_opa_skip(new_json, policy_title, provider_account_number)
        utils.debug_sprintf("module_resource: %s, skip=%s", [new_json.address, opa_skip])
        
        not opa_skip
        
        x2 := new_json
    ]
    
    resources := module_resource_list
} else := resources if {
    resources := []
}

#############################################################
# Warning Check Functions
#############################################################

# Check if S3 notification targets existing SNS topic
check_s3_notification_warning(resource, input_plan) := warning if {
    resource.type == "aws_s3_bucket_notification"
    
    after := resource.change.after
    after != null
    
    # Get topic configurations
    topics := object.get(after, "topic", [])
    some t
    topic := topics[t]
    topic_arn := object.get(topic, "topic_arn", "")
    
    # Topic ARN exists
    is_string(topic_arn)
    topic_arn != ""
    
    utils.debug_sprintf("s3_notification: checking topic_arn=%s", [topic_arn])
    
    # The SNS topic is NOT being created in this plan
    not topic_is_created_in_plan(topic_arn, input_plan)
    
    utils.debug_sprintf("s3_notification: WARNING - existing topic detected for %s", [resource.address])
    
    warning := {
        "severity": "WARNING",
        "policy": policy_title,
        "resource_address": resource.address,
        "resource_type": resource.type,
        "sns_topic_arn": topic_arn,
        "message": sprintf(
            "S3 bucket notification (%s) publishes to an existing SNS topic (%s). This pattern can overwrite the SNS topic policy. Validate the final topic policy and run an end-to-end notification test.",
            [resource.address, topic_arn]
        )
    }
}

# Check if SNS policy is being updated on existing topic
check_sns_policy_warning(resource, input_plan) := warning if {
    resource.type == "aws_sns_topic_policy"
    
    # Policy is being updated or replaced
    actions := resource.change.actions
    updates_or_replaces(actions)
    
    after := resource.change.after
    after != null
    topic_arn := object.get(after, "arn", "")
    
    utils.debug_sprintf("sns_policy: checking arn=%s, actions=%v", [topic_arn, actions])
    
    # Topic is NOT being created in this plan
    not topic_is_created_in_plan(topic_arn, input_plan)
    
    utils.debug_sprintf("sns_policy: WARNING - policy update on existing topic for %s", [resource.address])
    
    warning := {
        "severity": "WARNING",
        "policy": policy_title,
        "resource_address": resource.address,
        "resource_type": resource.type,
        "sns_topic_arn": topic_arn,
        "message": sprintf(
            "SNS topic policy (%s) for topic %s is being updated/replaced. Verify existing policy statements aren't being lost.",
            [resource.address, topic_arn]
        )
    }
}

#############################################################
# Helper Functions - Topic Detection
#############################################################

# Check if an SNS topic is being created in this plan
topic_is_created_in_plan(topic_arn, input_plan) {
    utils.debug_sprintf("topic_is_created_in_plan: checking ARN=%s", [topic_arn])
    
    # Try matching by ARN first
    some resource in input_plan.resource_changes
    resource.type == "aws_sns_topic"
    creates(resource.change.actions)
    
    after := resource.change.after
    after != null
    
    created_arn := object.get(after, "arn", "")
    is_string(created_arn)
    created_arn == topic_arn
    
    utils.debug_sprintf("topic_is_created_in_plan: matched by ARN in resource_changes", [])
}

topic_is_created_in_plan(topic_arn, input_plan) {
    # Fallback: match by topic name when ARN is not computed yet
    contains(topic_arn, "arn:aws:sns:")
    parts := split(topic_arn, ":")
    count(parts) >= 6
    topic_name := parts[5]
    
    utils.debug_sprintf("topic_is_created_in_plan: trying name match for %s", [topic_name])
    
    some resource in input_plan.resource_changes
    resource.type == "aws_sns_topic"
    creates(resource.change.actions)
    
    after := resource.change.after
    after != null
    created_name := object.get(after, "name", "")
    created_name == topic_name
    
    utils.debug_sprintf("topic_is_created_in_plan: matched by name in resource_changes", [])
}

topic_is_created_in_plan(topic_arn, input_plan) {
    # Check in modules too
    utils.debug_sprintf("topic_is_created_in_plan: checking modules for ARN=%s", [topic_arn])
    
    modules := get_modules
    some module
    module = modules[_]
    
    some resource
    resource = module.value.resources[_]
    resource.type == "aws_sns_topic"
    
    # Check ARN or name match
    after_arn := object.get(resource, "values.arn", "")
    after_arn == topic_arn
    
    utils.debug_sprintf("topic_is_created_in_plan: matched in module by ARN", [])
}

topic_is_created_in_plan(topic_arn, input_plan) {
    # Module name-based fallback
    contains(topic_arn, "arn:aws:sns:")
    parts := split(topic_arn, ":")
    count(parts) >= 6
    topic_name := parts[5]
    
    modules := get_modules
    some module
    module = modules[_]
    
    some resource
    resource = module.value.resources[_]
    resource.type == "aws_sns_topic"
    
    resource_name := object.get(resource, "values.name", "")
    resource_name == topic_name
    
    utils.debug_sprintf("topic_is_created_in_plan: matched in module by name", [])
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

#############################################################
# Skip Logic (Configuration-driven)
#############################################################

# Determine if an OPA check should be skipped based on configuration
is_opa_skip(resource, title, provider_account_number) := response if {
    utils.debug_sprintf("is_opa_skip: checking resource=%s, policy=%s", [resource.address, title])
    
    # Check if the policy title is in the configuration file
    opa_skip_list := data.variables.opa_exceptions[title]
    utils.debug_sprintf("is_opa_skip: skip_list=%v", [opa_skip_list])
    
    # Check that the list exists
    opa_skip_list
    
    # Loop through entries in the skip list
    some opa_skip_entry in opa_skip_list
    
    # Check account number
    utils.in_array(opa_skip_entry.approved_accounts, provider_account_number)
    
    utils.debug_sprintf("is_opa_skip: checking regex for %s", [resource.address])
    
    # Check regex pattern
    response := compare_regex_list_against_address(resource.address, opa_skip_entry)
    
    utils.debug_sprintf("is_opa_skip: result=%s", [response])
} else := response if {
    response := false
}

compare_regex_list_against_address(address, opa_skip_entry) := response if {
    utils.debug("compare_regex_list_against_address")
    
    # Get the regex from configuration
    pattern := opa_skip_entry.regex
    
    utils.debug_sprintf("comparing pattern: %s with address: %s", [pattern, address])
    
    # Check if pattern matches
    response := regex.match(pattern, address)
    
    utils.debug_sprintf("regex match result: %s", [response])
    
    response == true
} else := response if {
    response := false
}

#############################################################
# Utility Functions
#############################################################

# Get provider account number
get_provider_account_number := account_number if {
    provider_config := input.configuration.provider_config.aws
    account_number := provider_config.expressions.allowed_account_ids.constant_value[0]
} else := account_number if {
    account_number := null
}

# Find all modules
get_modules := all_modules_with_path if {
    all_modules_with_path := [v |
        some path, value
        walk(input.configuration, [path, value])
        count(path) > 0
        is_module(value)
        v := {
            "path": array.concat(["configuration"], path),
            "value": value,
        }
    ]
}

# Check if we are seeing a module
is_module(x) if {
    x.resources
}

is_module(x) if {
    x.module_calls
}

# Get the plan
get_plan := plan if {
    input.plan
    plan := input.plan
} else := plan if {
    not input.plan
    plan := input
}

# Replace value helper
replace_value(resource_key, field_name, new_value, old_value) := result if {
    resource_key == field_name
    result := new_value
} else := old_value





=======

at s3_sns_existing_topic_warn_test.rego
package terraform.module

import future.keywords.in

# Mock utils functions for testing
utils.debug(msg) := true
utils.debug_sprintf(fmt, args) := true
utils.in_array(arr, val) := true

#############################################################
# Test: S3 notification to EXISTING SNS topic → should WARN
#############################################################

test_s3_notification_existing_topic_warns {
    plan := {
        "resource_changes": [
            {
                "address": "aws_s3_bucket_notification.bucket_notify",
                "type": "aws_s3_bucket_notification",
                "mode": "managed",
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
        ],
        "configuration": {
            "provider_config": {
                "aws": {
                    "expressions": {
                        "allowed_account_ids": {
                            "constant_value": ["123456789012"]
                        }
                    }
                }
            }
        }
    }
    
    result := warnings with input as plan with data.variables.opa_exceptions as {}
    count(result) == 1
    some w in result
    w.policy == "s3-sns-notification-warning"
    w.sns_topic_arn == "arn:aws:sns:eu-west-1:123456789012:existing-topic"
}

#############################################################
# Test: S3 notification to NEW SNS topic → should NOT warn
#############################################################

test_s3_notification_new_topic_no_warning {
    plan := {
        "resource_changes": [
            {
                "address": "aws_sns_topic.new_topic",
                "type": "aws_sns_topic",
                "mode": "managed",
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
                "mode": "managed",
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
        ],
        "configuration": {
            "provider_config": {
                "aws": {
                    "expressions": {
                        "allowed_account_ids": {
                            "constant_value": ["123456789012"]
                        }
                    }
                }
            }
        }
    }
    
    result := warnings with input as plan with data.variables.opa_exceptions as {}
    count(result) == 0
}

#############################################################
# Test: Skip logic works when resource matches exception
#############################################################

test_skip_logic_prevents_warning {
    plan := {
        "resource_changes": [
            {
                "address": "module.approved_module.aws_s3_bucket_notification.bucket_notify",
                "type": "aws_s3_bucket_notification",
                "mode": "managed",
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
        ],
        "configuration": {
            "provider_config": {
                "aws": {
                    "expressions": {
                        "allowed_account_ids": {
                            "constant_value": ["123456789012"]
                        }
                    }
                }
            }
        }
    }
    
    opa_exceptions := {
        "s3-sns-notification-warning": [
            {
                "approved_accounts": ["123456789012"],
                "regex": "module\\.approved_module\\..*"
            }
        ]
    }
    
    result := warnings with input as plan with data.variables.opa_exceptions as opa_exceptions
    count(result) == 0  # Should be skipped due to exception
}

#############################################################
# Test: SNS policy UPDATE on existing topic → should WARN
#############################################################

test_sns_policy_update_existing_topic_warns {
    plan := {
        "resource_changes": [
            {
                "address": "aws_sns_topic_policy.topic_policy",
                "type": "aws_sns_topic_policy",
                "mode": "managed",
                "change": {
                    "actions": ["update"],
                    "after": {
                        "arn": "arn:aws:sns:eu-west-1:123456789012:existing-topic",
                        "policy": "{\"Version\":\"2012-10-17\",\"Statement\":[...]}"
                    }
                }
            }
        ],
        "configuration": {
            "provider_config": {
                "aws": {
                    "expressions": {
                        "allowed_account_ids": {
                            "constant_value": ["123456789012"]
                        }
                    }
                }
            }
        }
    }
    
    result := warnings with input as plan with data.variables.opa_exceptions as {}
    count(result) == 1
    some w in result
    w.policy == "s3-sns-notification-warning"
}

#############################################################
# Test: Name-based matching when ARN not computed
#############################################################

test_name_based_matching_works {
    plan := {
        "resource_changes": [
            {
                "address": "aws_sns_topic.new_topic",
                "type": "aws_sns_topic",
                "mode": "managed",
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
                "mode": "managed",
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
        ],
        "configuration": {
            "provider_config": {
                "aws": {
                    "expressions": {
                        "allowed_account_ids": {
                            "constant_value": ["123456789012"]
                        }
                    }
                }
            }
        }
    }
    
    result := warnings with input as plan with data.variables.opa_exceptions as {}
    count(result) == 0  # Should recognize topic is being created
}

#############################################################
# Test: No resources → no warnings
#############################################################

test_no_resources_no_warnings {
    plan := {
        "resource_changes": [],
        "configuration": {
            "provider_config": {
                "aws": {
                    "expressions": {
                        "allowed_account_ids": {
                            "constant_value": ["123456789012"]
                        }
                    }
                }
            }
        }
    }
    
    result := warnings with input as plan with data.variables.opa_exceptions as {}
    count(result) == 0
}


====

root@roberto-H610M-H-V3-DDR4:/data/opatest# cat utils.rego 
package utils

# Debug logging function - prints to trace in verbose mode
debug(msg) := true

# Debug logging with sprintf formatting
debug_sprintf(format, args) := true {
    # In production, this would log. For now, just return true
    true
}

# Check if value exists in array
in_array(arr, val) {
    arr[_] == val
}

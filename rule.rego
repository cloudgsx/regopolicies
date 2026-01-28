# METADATA
# title: ECP_AWS_S3_SNS_EXISTING_TOPIC_POLICY_OVERWRITE_WARN
# description: |
#   Warn when an S3 bucket notification publishes to an existing SNS topic ARN.
#   This can cause inadvertent SNS topic policy overwrites.
# custom:
#   evaluates: Terraform
#   resource_types:
#     - aws_s3_bucket_notification
#   cust_id: Global Technology - AWS
#   owner: dg.ecp_aws_engineering@bofa.com
#   level: MEDIUM
#   rule_id: ECP_AWS_S3_SNS_EXISTING_TOPIC_POLICY_OVERWRITE_WARN
#   internal_site: https://horizon.bankofamerica.com/docs/x/bMTgPg
#   external_site: https://horizon.bankofamerica.com/docs/x/bMTgPg
#   jira_story: ECPAWS-3316
package aws.aws_s3_bucket_notification.sns_existing_topic_policy_overwrite_warn

import data.terraform.module as terraform
import data.utils
import rego.v1

execute_rule(annotations, terraform_resource, suffix) := response if {
  # Extract values with fallbacks for when metadata isn't available (testing)
  rule_id := object.get(object.get(annotations, "custom", {}), "rule_id", "ECP_AWS_S3_SNS_EXISTING_TOPIC_POLICY_OVERWRITE_WARN")
  title := object.get(annotations, "title", "ECP_AWS_S3_SNS_EXISTING_TOPIC_POLICY_OVERWRITE_WARN")
  cust_id := object.get(object.get(annotations, "custom", {}), "cust_id", "Global Technology - AWS")
  owner := object.get(object.get(annotations, "custom", {}), "owner", "dg.ecp_aws_engineering@bofa.com")
  severity := object.get(object.get(annotations, "custom", {}), "level", "MEDIUM")
  internal_site := object.get(object.get(annotations, "custom", {}), "internal_site", "https://horizon.bankofamerica.com/docs/x/bMTgPg")
  external_site := object.get(object.get(annotations, "custom", {}), "external_site", "https://horizon.bankofamerica.com/docs/x/bMTgPg")
  jira_story := object.get(object.get(annotations, "custom", {}), "jira_story", "ECPAWS-3316")
  
  # Check that S3 bucket notifications exist
  terraform_resource.change.after.topic
  
  # Get the topic configurations for this S3 bucket notification
  topics := object.get(terraform_resource.change.after, "topic", [])
  
  # Check each topic to see if it's risky (existing, not created in this plan)
  some topic in topics
  topic_arn := object.get(topic, "topic_arn", "")
  startswith(topic_arn, "arn:aws:sns:")
  
  # Check if this topic is NOT being created in the same plan
  not topic_arn in sns_topics_created_in_plan
  
  response := terraform.ocsf_response(
    concat("", [rule_id, suffix]),
    concat("", [title, suffix]),
    {
      "message": {
        "RESOURCE": terraform_resource.address,
        "OPA ID": rule_id,
        "CONFIG RULE": title,
        "CUSTOMER ID": cust_id,
        "OWNER": owner,
        "SEVERITY": severity,
        "SNS TOPIC ARN": topic_arn,
        "DESCRIPTION": sprintf(
          "S3 bucket notification publishes to an existing SNS topic (%s). This may overwrite the SNS topic policy. Validate the final topic policy and run an end-to-end S3 → SNS notification test.",
          [topic_arn]
        ),
        "FIX DOCUMENTATION": {
          "ECP INTERAL": internal_site,
          "ECP GLOBAL": external_site
        },
        "JIRA Story": jira_story
      },
      "compliance": {"requirements": ["None"]},
      "resources": {
        "cloud_partition": "aws",
        "group_name": terraform_resource.type,
        "uid": terraform_resource.address
      }
    }
  )
}

# Set of SNS topic ARNs created in this plan
sns_topics_created_in_plan contains arn if {
  some rc in input.resource_changes
  rc.type == "aws_sns_topic"
  some action in rc.change.actions
  action == "create"
  after := rc.change.after
  after != null
  arn := after.arn
  arn != ""
}

# audit violation for create (new resource)
violations contains response if {
  chain := rego.metadata.chain()
  annotations := utils.package_annotations(chain)
  
  # Fallback values for testing when metadata is empty
  title := object.get(annotations, "title", "ECP_AWS_S3_SNS_EXISTING_TOPIC_POLICY_OVERWRITE_WARN")
  
  # check to see if this policy is in the included_policies
  # section of the variable file
  title != ""
  
  some terraform_resource in terraform.of_types_and_actions(
    object.get(object.get(annotations, "custom", {}), "resource_types", ["aws_s3_bucket_notification"]), 
    ["create"], 
    title
  )
  response := execute_rule(annotations, terraform_resource, "")
}

# audit violation for update, no-op (existing resource)
violations contains response if {
  chain := rego.metadata.chain()
  annotations := utils.package_annotations(chain)
  
  # Fallback values for testing when metadata is empty
  title := object.get(annotations, "title", "ECP_AWS_S3_SNS_EXISTING_TOPIC_POLICY_OVERWRITE_WARN")
  
  # check to see if this policy is in the included_policies
  # section of the variable file
  title != ""
  
  some terraform_resource in terraform.of_types_and_actions(
    object.get(object.get(annotations, "custom", {}), "resource_types", ["aws_s3_bucket_notification"]), 
    ["no-op", "update"], 
    title
  )
  response := execute_rule(annotations, terraform_resource, "")
}

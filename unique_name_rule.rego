# METADATA
# title: ECP_AWS_SNS_TOPIC_UNIQUE_NAME_CHECK
# description: |
#   Ensures that SNS topic names are unique across the Terraform plan.
#   Duplicate topic names will cause Terraform apply to fail.
# custom:
#   evaluates: Terraform
#   resource_types:
#     - aws_sns_topic
#   cust_id: Global Technology - AWS
#   owner: dg.ecp_aws_engineering@bofa.com
#   level: HIGH
#   rule_id: ECP_AWS_SNS_TOPIC_UNIQUE_NAME_CHECK
#   internal_site: https://horizon.bankofamerica.com/docs/x/bMTgPg
#   external_site: https://horizon.bankofamerica.com/docs/x/bMTgPg
#   jira_story: ECPAWS-XXXX
package aws.aws_sns_topic.unique_name_check

import data.terraform.module as terraform
import data.utils
import rego.v1

execute_rule(annotations, terraform_resource, suffix) := response if {
  # Extract values with fallbacks for when metadata isn't available (testing)
  rule_id := object.get(object.get(annotations, "custom", {}), "rule_id", "ECP_AWS_SNS_TOPIC_UNIQUE_NAME_CHECK")
  title := object.get(annotations, "title", "ECP_AWS_SNS_TOPIC_UNIQUE_NAME_CHECK")
  cust_id := object.get(object.get(annotations, "custom", {}), "cust_id", "Global Technology - AWS")
  owner := object.get(object.get(annotations, "custom", {}), "owner", "dg.ecp_aws_engineering@bofa.com")
  severity := object.get(object.get(annotations, "custom", {}), "level", "HIGH")
  internal_site := object.get(object.get(annotations, "custom", {}), "internal_site", "https://horizon.bankofamerica.com/docs/x/bMTgPg")
  external_site := object.get(object.get(annotations, "custom", {}), "external_site", "https://horizon.bankofamerica.com/docs/x/bMTgPg")
  jira_story := object.get(object.get(annotations, "custom", {}), "jira_story", "ECPAWS-XXXX")
  
  # Get the topic name
  topic_name := terraform_resource.change.after.name
  topic_name != ""
  
  # Check if this name is used by multiple resources
  topic_count := count_topics_with_name(topic_name)
  topic_count > 1
  
  # Get all resources using this name
  affected_resources := get_resources_with_name(topic_name)
  
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
        "TOPIC NAME": topic_name,
        "DUPLICATE COUNT": topic_count,
        "AFFECTED RESOURCES": affected_resources,
        "DESCRIPTION": sprintf(
          "Duplicate SNS topic name detected: '%s'. SNS topic names must be unique within an AWS account and region. %d resources attempt to create topics with the same name: %s. Terraform apply will fail.",
          [topic_name, topic_count, concat(", ", affected_resources)]
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

# Count how many resources use a given topic name
count_topics_with_name(topic_name) := total if {
  total := count([1 |
    some rc in input.resource_changes
    rc.type == "aws_sns_topic"
    some action in rc.change.actions
    action in ["create", "update"]
    after := rc.change.after
    after != null
    name := object.get(after, "name", "")
    name == topic_name
  ])
}

# Get all resource addresses that use a specific topic name
get_resources_with_name(topic_name) := sorted if {
  addrs := [rc.address |
    some rc in input.resource_changes
    rc.type == "aws_sns_topic"
    some action in rc.change.actions
    action in ["create", "update"]
    after := rc.change.after
    after != null
    name := object.get(after, "name", "")
    name == topic_name
  ]
  sorted := sort(addrs)
}

# audit violation for create (new resource)
violations contains response if {
  chain := rego.metadata.chain()
  annotations := utils.package_annotations(chain)
  
  # Fallback values for testing when metadata is empty
  title := object.get(annotations, "title", "ECP_AWS_SNS_TOPIC_UNIQUE_NAME_CHECK")
  
  # check to see if this policy is in the included_policies
  # section of the variable file
  title != ""
  
  some terraform_resource in terraform.of_types_and_actions(
    object.get(object.get(annotations, "custom", {}), "resource_types", ["aws_sns_topic"]), 
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
  title := object.get(annotations, "title", "ECP_AWS_SNS_TOPIC_UNIQUE_NAME_CHECK")
  
  # check to see if this policy is in the included_policies
  # section of the variable file
  title != ""
  
  some terraform_resource in terraform.of_types_and_actions(
    object.get(object.get(annotations, "custom", {}), "resource_types", ["aws_sns_topic"]), 
    ["no-op", "update"], 
    title
  )
  response := execute_rule(annotations, terraform_resource, "")
}

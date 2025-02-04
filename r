Jira Stories
1. Investigation: Impact Analysis of Azure RM Provider Upgrade
Summary: Analyze the impact of upgrading Azure RM Provider from v3.113 to v4.11.0
Description:
Identify deprecated features and breaking changes between v3.113 and v4.11.0.
Document potential risks and required modifications in Terraform configurations.
Provide recommendations for necessary code updates.
Assignee: [Your Team/Person]
Priority: High
Acceptance Criteria:
A detailed report on changes and their impact.
List of deprecated resources, attributes, and required modifications.
Recommendations for mitigation strategies.
2. Migration: Upgrade Azure RM Provider to v4.11.0
Summary: Upgrade the Azure RM provider to v4.11.0 in TFE Dev.
Description:
Apply necessary Terraform module updates based on the findings from the impact analysis.
Modify infrastructure code to be compatible with v4.11.0.
Ensure all dependent modules are updated accordingly.
Assignee: [Your Team/Person]
Priority: High
Acceptance Criteria:
Terraform configurations are updated and successfully applied in Dev.
No breaking changes or unintended failures in the environment.
Code is ready for functional testing.
3. Testing: Validate the Upgrade in Dev Environment
Summary: Test the upgraded Azure RM Provider v4.11.0 in TFE Dev.
Description:
Execute Terraform plan and apply with the updated provider.
Validate that all resources are created/updated as expected.
Identify and resolve any errors.
Perform regression testing on key infrastructure components.
Assignee: [Your Team/Person]
Priority: High
Acceptance Criteria:
Successful execution of Terraform scripts with the new provider version.
No critical errors or regressions.
Documentation of test results and any necessary fixes.
I will now perform an impact analysis by comparing the deprecations and breaking changes between Azure RM Provider v3.113 and v4.11.0.

Upgrading from AzureRM Provider version 3.113 to 4.11.0 involves several breaking changes and deprecations that need to be addressed. Here's a summary of the key changes:

1. Subscription ID Requirement
Change: The subscription_id is now a mandatory property in the provider configuration.
Impact: Terraform configurations that relied on Azure CLI's default subscription context will now fail without specifying the subscription_id.
Action: Explicitly set the subscription_id in your provider configuration or through the ARM_SUBSCRIPTION_ID environment variable.
2. Removed Resources and Data Sources
Change: Deprecated resources and data sources have been removed in version 4.0.
Impact: Configurations using these deprecated entities will fail upon upgrading.
Action: Identify and replace deprecated resources with their updated counterparts.
3. Provider Property Changes
Change: The skip_provider_registration property has been removed.
Impact: Configurations using this property will encounter errors.
Action: Use the new resource_provider_registrations and resource_providers_to_register properties to manage resource provider registrations.
4. Azure Kubernetes Service (AKS) Changes
Change: The azurerm_kubernetes_cluster resource now uses only the stable API version.
Impact: Certain arguments previously available may no longer be supported.
Action: Review and update AKS configurations to align with the stable API.
5. Database Resource Changes
Change: Older database resources are being replaced with new ones (e.g., azurerm_sql_* replaced by azurerm_mssql_*).
Impact: Existing configurations using deprecated database resources need to be updated.
Action: Migrate to the new database resources as per the upgrade guide.
6. List to Set Conversion
Change: Certain properties in resources like azurerm_subnet and azurerm_virtual_network have changed from accepting lists to sets.
Impact: This affects how these properties are defined and accessed in configurations.
Action: Update configurations to define these properties as sets and adjust any references accordingly.
For a comprehensive list of changes and detailed guidance, please refer to the AzureRM Provider 4.0 Upgrade Guide.

By addressing these changes, you can ensure a smooth transition to AzureRM Provider version 4.11.0.

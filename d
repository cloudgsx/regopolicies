AC1: Terraform Provider Source Update for Compliance and Standardization
Given that the Terraform configuration requires an update to align with provider sourcing standards,
When the provider source for the random provider is updated to AzurePMR in tf_azr_lz_policy_l1,
Then Terraform should successfully retrieve the provider from AzurePMR across different environments to ensure compliance with organizational infrastructure standards.
AC2: Structured Input Files for CORP Build Standardization
Given that PROD input files need to be updated to ensure consistency across CORP environments,
When dev.auto.tfvars, uat.auto.tfvars, and prod.auto.tfvars files are updated,
Then they should be clearly structured following CORP standards, properly configured to align with environment-specific requirements, and correctly referenced within the Terraform execution process for CORP builds.
AC3: Ensuring Terraform Configuration Enables Consistent Policy Enforcement
Given that the Terraform configuration update must maintain compliance with security and policy enforcement,
When the updated provider and input files are implemented,
Then the Terraform configuration should enforce infrastructure policies consistently across all CORP environments, prevent unauthorized modifications to security-sensitive configurations, and maintain compatibility with existing CORP policy modules to avoid disruptions.

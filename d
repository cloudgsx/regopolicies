Story Title:
Integrate New Jenkins Library & Support CORP Buildout in Landing Zone

Type:
Story

Priority:
Major

Resolution:
Unresolved

Epic Link:
Build (CORP:APP-DEV) Landing Zones in CORP | APP DEV environment

Story Type:
Feature

Test Scope:
Dev + Test

Acceptance Criteria:
CI/CD pipelines successfully leverage the new Jenkins library.
Input files for CORP/dev and CORP/uat deployments are clearly defined in tf_azr_lz_app_L2.
Deployment process is successful and verified.
Story Points:
2

TeamHQ Team:
ECP Ops Technology (External Cloud SRE) - 20553

Sprint:
ECP.IAC.25.P1.S0

Ready:
Yes

CRQ ID:
CRQ000013570470

Release Key Link:
[RM-ECPIAC-ECPIAC-2]

Impacted AITs:
Microsoft Azure - Cloud Services - 71148

Description:
Enhance the landing zone template to integrate the new Jenkins library for CI/CD workflows using XLR. Ensure that the template fully supports CORP buildout by providing the necessary input files.

Jenkins Library Reference: @Library('hotfix')
How to use Jenkins Library: Terraform AppAC Pipeline Documentation












Description:
Enhance the Terraform configuration in the tf_azr_lz_policy_l1 landing zone by updating the provider source for the random provider to AzurePMR. Additionally, add PROD input files in the CORP folder to ensure consistency across all relevant environments.

This change ensures that Terraform retrieves the provider from AzurePMR across different environments and that PROD input files are correctly structured and updated.

Acceptance Criteria:
Update the provider source for the random provider to AzurePMR in the tf_azr_lz_policy_l1 landing zone.
Verify that the updated provider functions correctly in all environments post-implementation.
Ensure PROD input files (dev.auto.tfvars, uat.auto.tfvars, prod.auto.tfvars) are updated and ready for the CORP build.

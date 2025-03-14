AC1: Key Vault Premium Module Execution & Configuration Validation
Given that the Key Vault Premium module is executed in the CORP-UAT environment using Terraform,
When the module is deployed,
Then Key Vault Premium resources should be visible in the Azure portal with the expected configurations, including Soft Delete enabled, Purge Protection enabled, and Public Network Access disabled.
AC2: Compliance Validation & Enforcement
Given that organizational compliance policies (e.g., Sentinel policies) are in place,
When resources are deployed using the module,
Then all deployed resources must meet compliance requirements, and any non-compliant resources must trigger an error message specifying the failed compliance checks.
AC3: Dependent Resource Creation & Linkage Validation
Given that the Key Vault Premium module includes dependent resources such as Role Assignments,
When these dependent resources are created,
Then they should be correctly linked to the respective Key Vault instances based on defined values in the input files.
AC4: Diagnostic & Post-Deployment Validation
Given that the Key Vault Premium module deployment is complete,
When resources are inspected post-deployment,
Then all deployed resources should be accessible in the Azure portal, diagnostic settings should be correctly configured, and all Azure policies should be in compliance.
AC5: Error Handling & Reporting for Misconfigurations
Given that a deployment is initiated with incorrect or missing configurations,
When the deployment process fails,
Then clear error messages must be displayed, detailing specific compliance or configuration issues to guide corrective actions.
Summary of Fixes:
✔ Merged redundant ACs (AC3 & AC4 into AC1).
✔ Removed focus on deployment execution and reworded for measurable validation.
✔ Specified compliance failure handling to ensure the correct triggers and error messaging are captured.
✔ Removed AC7 (Test Artifacts), as it was not an actual requirement but rather a process step.

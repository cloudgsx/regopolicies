Azure Rego Policy
This Rego policy validates that Azure AD user assignments meet the specified requirements:

Multi-Factor Authentication (MFA) must be enabled.
MFA expiration must not exceed 90 days.
Privileged Identity Management (PIM) entitlements must be checked.

package azure.ad_user_policy

# Allow if MFA is enabled and all conditions are met
allow {
    mfa_enabled
    valid_mfa_expiration
    valid_pim_entitlement
}

# MFA must be enabled
mfa_enabled {
    input.mfa_enabled == true
}

# MFA expiration must not exceed 90 days
valid_mfa_expiration {
    mfa_expiration := input.mfa_expiration
    days_limit := 90
    mfa_expiration <= days_limit
}

# PIM entitlement settings must be correct
valid_pim_entitlement {
    pim_entitlement := input.pim_entitlement
    pim_entitlement == "approved"
}

# Deny if any condition is not met
deny {
    not mfa_enabled
    not valid_mfa_expiration
    not valid_pim_entitlement
}


JSON Terraform Mock Test Cases

Test Case 1: Compliant User Assignment
Input:


{
  "user_principal_name": "test@company.com",
  "display_name": "Test User",
  "password": "random_password",
  "mfa_enabled": true,
  "mfa_expiration": 60,
  "pim_entitlement": "approved"
}
Expected Output:


{
  "allow": true,
  "deny": false
}

Test Case 2: Non-Compliant MFA Disabled
Input:

{
  "user_principal_name": "test@company.com",
  "display_name": "Test User",
  "password": "random_password",
  "mfa_enabled": false,
  "mfa_expiration": 60,
  "pim_entitlement": "approved"
}
Expected Output:


{
  "allow": false,
  "deny": true
}

Test Case 3: Non-Compliant MFA Expiration Exceeded
Input:
{
  "user_principal_name": "test@company.com",
  "display_name": "Test User",
  "password": "random_password",
  "mfa_enabled": true,
  "mfa_expiration": 120,
  "pim_entitlement": "approved"
}
Expected Output:


{
  "allow": false,
  "deny": true
}

Test Case 4: Non-Compliant PIM Entitlement
Input:

{
  "user_principal_name": "test@company.com",
  "display_name": "Test User",
  "password": "random_password",
  "mfa_enabled": true,
  "mfa_expiration": 60,
  "pim_entitlement": "not_approved"
}
Expected Output:


{
  "allow": false,
  "deny": true
}


Documentation (README.md)
# Azure AD User Policy

## Overview

This Rego policy ensures that Azure AD user assignments comply with security best practices:
1. **MFA Validation**: Ensures Multi-Factor Authentication (MFA) is enabled.
2. **MFA Expiration Period**: Validates that MFA expiration does not exceed 90 days.
3. **PIM Entitlement**: Checks for approved Privileged Identity Management (PIM) entitlements.

## Policy Implementation

The policy is implemented in `policy.rego` and evaluates input against the following criteria:
- **MFA Enabled**: `mfa_enabled` must be `true`.
- **MFA Expiration**: `mfa_expiration` must be within 90 days.
- **PIM Entitlement**: `pim_entitlement` must be `"approved"`.

If any of these conditions are not met, the policy denies the resource creation.

## Test Cases

Mock test cases in JSON format validate the policy behavior. Example scenarios include:
- Valid assignments with all conditions met.
- Invalid assignments due to disabled MFA, exceeded MFA expiration, or incorrect PIM entitlements.

### Example Test Case

Input:
```json
{
  "user_principal_name": "test@company.com",
  "display_name": "Test User",
  "password": "random_password",
  "mfa_enabled": true,
  "mfa_expiration": 60,
  "pim_entitlement": "approved"
}
Expected Output:


{
  "allow": true,
  "deny": false
}

How to Use
Prerequisites
Open Policy Agent (OPA)
JSON input files representing Azure AD user configurations.
Running the Policy
Save the policy in policy.rego.
Save test cases in test_cases.json.
Run the tests using OPA:
bash
Copiar código
opa test policy.rego test_cases.json
Evaluate Input
To evaluate a single input:


opa eval --input input.json --data policy.rego "data.azure.ad_user_policy.allow"
Replace input.json with the specific input file.

Acceptance Criteria
Success:

Validates MFA configuration for new accounts.
Checks PIM entitlement settings.
Enforces MFA expiration periods.
Integrates with Azure AD configurations.
Provides an audit trail of checks.
Failure:

Missing MFA validation.
Incorrect PIM entitlement checks.
MFA expiration not enforced.
Integration failures.
Incomplete audit trails.

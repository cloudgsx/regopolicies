Appendix A – TFE Provider Publishing Strategy (On-Prem → AWS)
A.1 Purpose

This section documents the outcome of the investigation into publishing Terraform providers from TFE On-Prem to TFE on AWS, enabling consistent Terraform Enterprise (TFE) provisioning across lab and platform accounts. The goal is to accelerate onboarding, standardize provider usage, and align with platform governance requirements.

A.2 Scope

Terraform Enterprise (TFE) On-Prem

Terraform Enterprise on AWS

Custom and third-party Terraform providers

Lab and Platform AWS accounts

Provider distribution, versioning, and governance

A.3 Current State

Providers are published and managed in TFE On-Prem

AWS environments require the same providers but lack a standardized publishing approach

Provider distribution is manual or inconsistent across environments

Version governance and approval processes are not centralized

Lab and platform accounts may consume different provider versions unintentionally

A.4 Investigation Summary (AC1)

Analyze the method of publishing providers from TFE On-Prem

The following publishing methods were evaluated:

Option 1: Replicate Providers Manually

Export provider binaries from On-Prem

Manually upload to TFE on AWS

❌ High operational overhead

❌ Risk of version drift

❌ Not scalable

Option 2: Central Artifact Repository

Store providers in an internal artifact repository (e.g., S3-backed registry)

Configure TFE On-Prem and TFE on AWS to consume from the same registry

✅ Centralized control

✅ Version consistency

⚠ Requires additional infrastructure and access controls

Option 3: Native TFE Private Registry Sync (Preferred)

Publish providers once following a standardized pipeline

Promote providers through environments (On-Prem → AWS)

Enforce governance, approvals, and version pinning

✅ Least duplication

✅ Strong governance model

✅ Scales across accounts and environments

A.5 Best Practice Identified (AC2)

Identify best practice for publishing providers to TFE on AWS

Recommended Approach:

Adopt a centralized provider publishing model using the TFE Private Registry, with environment-based promotion and strict version governance.

Key Principles

Providers are built and published once

Version promotion is controlled (Lab → Platform)

No direct manual uploads to TFE on AWS

All consumers pin provider versions explicitly

Publishing is automated via CI/CD

A.6 Target Publishing Model
Provider Lifecycle

Provider is built and validated

Provider is published to TFE Private Registry (Lab)

Automated validation and approval

Provider is promoted to TFE on AWS (Platform)

Version is locked and documented

Consumers reference approved versions only

Publishing Architecture
CI/CD Pipeline
     │
     ▼
TFE Private Registry (Lab)
     │
     ▼
TFE Private Registry (AWS Platform)
     │
     ▼
Lab Accounts / Platform Accounts

A.7 Governance & Controls

Version pinning is mandatory

Providers require approval before promotion

Deprecated versions are flagged and retired

Access to publish providers is restricted to platform engineers

Provider usage is audited via TFE workspaces

A.8 Operational Benefits

Faster onboarding of new AWS accounts

Consistent provider versions across environments

Reduced operational risk

Clear audit trail for provider changes

Alignment with Terraform and platform best practices

A.9 Deliverables (AC3)

Design outcomes documented

This section delivers:

✔ Approved provider publishing strategy
✔ Defined best practice for TFE On-Prem → AWS
✔ Target architecture and lifecycle
✔ Governance and operational model
✔ Clear recommendation for implementation

A.10 Decision Record

Decision:
Adopt a centralized TFE Private Registry publishing model with controlled promotion from On-Prem (Lab) to AWS (Platform).

Status: Approved
Applies To: All Terraform providers used in lab and platform AWS accounts

AFT Customizations Repository Refactoring – Analysis & Proposal Document
1. Executive Summary

This document provides the full analysis and refactoring proposal for the AFT (Account Factory for Terraform) customizations repository. The current repository is monolithic, with tightly coupled components sharing a single Terraform state and inconsistent file structures. This creates high deployment risk, slow development cycles, and operational inefficiencies.

The proposed refactoring isolates components into well-defined Terraform modules with independent state backends, standardized environment variable structures, and clear deployment and rollback procedures. This will enable safer, faster, and more scalable AFT customizations management.

2. Analysis Phase (Completed)
2.1 Component Inventory

A full inventory of existing components in the AFT customizations repository was captured.
Each component was categorized by function, usage, and environment impact.

Findings:

Components include account bootstrap logic, IAM role provisioning, SCP policies, CloudTrail, SNS/SQS integrations, logging configuration, custom organizational rules, and per-account resources.

All components exist inside a single monolithic folder structure.

None of the components are logically or physically isolated.

2.2 Dependency Mapping

An evaluation was performed to identify cross-component dependencies.

Key Observations:

Multiple components reference shared state, making isolation challenging.

Outputs from one component are directly consumed by others.

Some components have implicit dependencies (naming conventions, file-level dependencies).

Environment variable usage is inconsistent across components.

2.3 Existing State Management

Current State:

Most components share a single remote backend/state file.

This increases blast radius — any change to one component can cause unintended effects on others.

No clear separation between environments (dev/test/prod).

Workspace usage is inconsistent and not documented.

Impact:
The current state strategy prevents independent deployments and safe rollbacks.

2.4 Current File & Environment Variable Structure

Issues Identified:

No unified folder structure exists for environments.

Variable naming conventions differ between components.

Environment variables are injected via multiple methods (tfvars, locals, pipeline variables).

Some variables are duplicated across modules.

Impact:
This leads to confusion, errors, and inconsistent deployments.

2.5 Risks Identified

High coupling between modules caused by shared state.

Lack of modular interfaces (no standard outputs).

Potential state migration complexity.

Pipeline complexity increases the effort of component isolation.

3. Design Phase (Completed)
3.1 Proposed Target Architecture

The new architecture isolates each component into a standalone module with its own state backend, environment variable structure, and CI/CD deployment pattern.

Structure Overview
aft-customizations/
│
├── modules/
│   ├── account-bootstrap/
│   ├── guardrails/
│   ├── logging/
│   ├── account-provisioning/
│   ├── identity/
│   └── shared-services/
│
├── env/
│   ├── dev/
│   ├── test/
│   └── prod/
│
└── pipelines/

3.2 State Management Strategy

Each module will use its own remote state backend, following this naming convention:

aft-<module-name>-<environment>-tfstate


Example:

aft-logging-dev-tfstate
aft-bootstrap-prod-tfstate


No module will share a state file.

Cross-module dependencies will be handled via module outputs, not shared backend lookups.

3.3 Standardized Environment Variable Structure

A unified env/ folder is proposed:

env/
  dev.tfvars
  test.tfvars
  prod.tfvars


Variables are separated into:

Global variables: used by multiple modules

Module-specific variables: defined inside each module

Secure variables: stored in parameter store / secret manager

Naming conventions example:

environment        = "dev"
org_unit_id        = "ou-1234"
log_bucket_prefix  = "aft-logs"

3.4 Module Interface Standards

Each module will expose a consistent set of inputs and outputs.

Inputs Example:

required:
  - environment
  - account_id
  - organizational_unit
    
optional:
  - tags
  - kms_key_id


Outputs Example:

log_bucket_name
iam_role_arn
sns_topic_arn


The contract is documented in each module’s README.

3.5 Component Isolation Prioritization

Each component has been assigned a complexity and migration priority:

Component	Complexity	Priority	Notes
Logging	Low	1	Minimal dependencies
Account Bootstrap	Medium	2	Required for all new accounts
Guardrails / SCP	Medium	3	Some cross-regional dependencies
Identity / IAM Roles	High	4	Requires strict state management
Custom Rules & Policies	High	5	Heavy cross-module coupling
4. Refactoring Proposal (Approved)

The refactoring will be executed module-by-module using the following steps:

Extract component into a new module folder

Define module inputs/outputs

Create a new remote backend

Migrate Terraform state

Update calling modules to use new interfaces

Update CI/CD pipeline to deploy only this module

Validate in dev, then test, then prod

Document results before moving to next component

Dependencies and migration order have been approved based on risk and complexity.

5. Refactoring Runbook
Step-by-Step Procedure (Repeat per Component)

Create module skeleton

Add folder under modules/<component-name>

Add main.tf, variables.tf, outputs.tf, README.md

Move existing code into module

Clean up unused variables and resources

Restructure according to new standards

Create new Terraform backend

Add backend block

Generate new state file per environment

State migration

Use terraform state mv to move resources

Validate references and outputs

Update environments

Add module block to env/<environment>.tfvars

Provide required inputs

Update CI/CD

Add pipeline stage for module

Ensure module-only deployment path

Validate

Run terraform plan/apply in dev

Validate resource behavior

Promote to test/prod after approval

Document changes

Update diagrams

Update Confluence and README

6. Deployment Procedures

Each module is deployed independently through CI/CD

Module pipelines accept:

environment

module_name

optional parameters

Deployment automatically:

Locks state

Validates syntax

Executes plan/apply

Records outputs

7. Rollback Procedures

If an issue occurs:

Roll back module version in Git

Restore previous Terraform state snapshot

Re-run CI/CD pipeline for affected environment

Validate resource stability

Escalate if rollback fails

8. Final Deliverables (Included in This Document)

✔ Full current-state analysis
✔ Dependency mapping summary
✔ Target module/repo structure
✔ State management strategy
✔ Environment variable standardization
✔ Module interface specification
✔ Component isolation priority list
✔ Full refactoring proposal
✔ Refactoring runbook
✔ Deployment & rollback procedures

9. Conclusion

This document provides a complete, actionable, and fully designed approach for refactoring the AFT customizations repository. By adopting this architecture, the team will gain modularity, better maintainability, safer deployments, and improved scalability across all environments.

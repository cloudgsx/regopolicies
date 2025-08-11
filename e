Title: Identify Approach for Workload Automation Pattern Migration

Story:
As an SRE, I want to identify and document the approach to obtain and configure the listed prerequisites (SPK, repos, pipelines, workspace deployments, repo migrations, etc.), so that we can move workloads from on-prem to the cloud with automation opportunities identified and planned.

Description:
This story covers the discovery and planning phase for the workload automation migration from on-prem to AWS. The scope includes identifying the process, tools, and dependencies for:

Getting SPK.

Accessing and preparing BitBucket repos.

Setting up deployment pipelines for software migration (on-prem to cloud).

Configuring TFE workspaces for cloud deployment.

Migrating GitHub repos to BitBucket.

Updating BitBucket code to reference TFE Registry modules instead of SSH to GitHub.

Retiring Archie GitHub repos.

Identifying automation opportunities.

Future considerations include infrastructure lifecycle testing, on-prem connectivity for frontend teams, and AWS ingress verification.

Acceptance Criteria:

A documented step-by-step plan exists for each of the 8 listed tasks.

Dependencies, required permissions, and tools for each step are identified.

Risks and blockers are documented.

A list of automation candidates is created, with priorities noted.

Recommendations for future testing scenarios (destroy/rebuild infra, ingress testing, on-prem connectivity) are documented.

Tasks:

Document how to obtain SPK.

Identify source and access requirements for BitBucket repos.

Outline steps to set up deployment pipeline for software migration.

Document TFE workspace configuration and deployment steps.

Identify and document GitHub to BitBucket migration process.

Determine how to update BitBucket code to use TFE Registry modules.

Document plan for retiring Archie GitHub repos.

Evaluate and list what can be automated (include short-term and long-term).

Definition of Done:

All discovery work is documented in Confluence or equivalent knowledge base.

Stakeholders review and approve the documented plan.

Future enhancement items are logged in Jira for follow-up.


A.10 Provider Intake Control Model (GIS Focused)

This section defines how Terraform providers are introduced into Artifactory, who is allowed to publish them, and how GIS and Security approve provider content before it is made available to Terraform Enterprise (TFE).

Artifactory is treated as a controlled artifact repository, not an open upload location.

A.11 Who Can Publish to Artifactory
Publishing Access

Only the following actors are permitted to publish provider binaries into Artifactory:

CI/CD service accounts owned by the Platform team

No individual user uploads are allowed

No direct uploads from developer workstations

This ensures:

Repeatable builds

Full auditability

No unapproved binaries

A.12 How Providers Enter Artifactory (Step-by-Step)
Step 1 – Provider Request

A provider introduction or version update is requested via:

Jira ticket (or equivalent change request)

Request includes:

Provider name & namespace

Source repository (GitHub, internal repo)

Requested version

Intended use case

Step 2 – Build in Controlled CI/CD

Provider source is pulled from an approved repository

Build occurs in a hardened CI/CD environment

No external binaries are accepted

Checksums and signatures are generated

Step 3 – Security & GIS Review

Before upload:

GIS/Security reviews:

Provider source repository

License and compliance

Known vulnerabilities

Approval is recorded in the ticketing system

Only approved requests proceed to upload

Step 4 – Upload to Artifactory

CI/CD pipeline uploads provider binary to Artifactory

Upload uses:

Service account credentials

Restricted repository path

Artifactory enforces:

Immutable artifacts

Version naming conventions

Metadata tagging (approval ID, owner)

Step 5 – Artifact Scanning & Validation

Artifactory performs:

Malware scanning

Vulnerability scanning

Checksum validation

Failed scans block promotion

Step 6 – Promotion to “Approved” Repository

Artifacts initially land in a staging repository

GIS/Security approval triggers promotion to:

terraform-providers-approved

Only approved repositories are accessible to TFE

A.13 Artifactory Repository Layout
terraform-providers/
├── staging/
│   └── company/
│       └── provider/
│           └── 1.2.3/
├── approved/
│   └── company/
│       └── provider/
│           └── 1.2.3/
└── deprecated/


staging: pending approval

approved: consumable by TFE

deprecated: blocked for new usage

A.14 Enforcement & Guardrails
Control	Enforcement
Upload restriction	CI/CD service accounts only
Manual uploads	Disabled
Approval required	GIS / Security
Artifact immutability	Enabled
Provider scanning	Mandatory
Access to approved repo	TFE only
A.15 How TFE Uses Approved Providers

TFE is configured to only read from the approved repository

TFE cannot access staging or deprecated repositories

Workspaces cannot bypass Artifactory

Provider versions must be explicitly pinned

A.16 Audit & Compliance

Every provider upload is traceable to:

CI/CD pipeline

Approval ticket

Upload timestamp

Artifactory access logs retained per policy

Provider usage can be audited via TFE workspace logs

A.17 Security Assurance Summary (GIS Ready)

No ad-hoc uploads

No developer workstations involved

No unapproved binaries

Centralized approval and scanning

Immutable and auditable artifacts

Clear separation of duties

A.18 Decision Record

Decision:
All Terraform providers consumed by TFE must be introduced into Artifactory only via approved CI/CD pipelines, with mandatory GIS/Security review and promotion controls.

Status: Pending GIS final approval
Applies To: All Terraform providers (custom and third-party)

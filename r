Title: Implement Azure Image Creation Pipeline Architecture

Story:
As a DevOps engineer,
I want to implement a structured image creation pipeline using Azure services,
So that we can streamline the creation, management, and deployment of VM images across environments (Dev, Test, Prod).

Description: Implement a pipeline for image creation and deployment in Azure, following the architecture outlined below:

Azure Subscriptions (Dev, Test, Prod):
Represent environments with isolated resources.

Azure DevOps:

Orchestration layer.

Triggers pipelines for image creation.

Connects to repositories (base configs, scripts, agents).

Pushes to different environments.

Azure Image Builder:

Builds images from base (Windows/Linux).

Injects configurations and software.

Uses JSON templates and Azure Resource Manager.

Optional Tools/Scripts:

Inject tools like Chocolatey, PowerShell scripts, DSC.

Shared Image Gallery (SIG):

Publishes images.

Manages versions and replicas.

Supports replication across subscriptions/regions.

VM / VMSS Deployments:

Uses images from SIG for deployment.

Supports individual or scale set VMs.

Azure Active Directory & RBAC:

Controls access (subscriptions, image builder, DevOps agents).

Roles: contributor, image publisher, etc.

Security Review Layer (CADA / Security Team):

Ensures compliance, hardening, integrity.

Optional integration: Azure Security Center / Defender for Cloud.

Can use Azure Policy or Custom Initiative for baselining.

Internal Repo Connections:

Connects to private repos (Artifactory, GitHub Enterprise).

Dotted lines to indicate optional dependencies.

Acceptance Criteria:

 Image creation pipeline triggers successfully from Azure DevOps.

 Custom scripts and tools are injected into the image.

 Images are published and managed in SIG.

 VM/VMSS deployments use SIG images.

 Access is controlled via AAD and RBAC.

 Security review process is integrated.

 External/internal repo connections are functional.

🔷 Azure Subscriptions (Dev, Test, Prod)
These are shown as separate blocks, representing isolation between environments. Each has its own resources and role assignments.

🛠️ Azure DevOps (Top-Left Corner)
Acts as the orchestration layer:

Triggers pipelines to start the image creation process.

Connects to repositories for base configs, custom scripts, or agents.

Pushes to different environments (Dev/Test/Prod).

📦 Azure Image Builder
Central component for:

Building images from a base (e.g., Windows/Linux)

Injecting configurations and software

Using JSON templates and Azure Resource Manager

🧰 Optional tools/scripts are injected during this process (e.g., Chocolatey, PowerShell scripts, DSC).

🖼️ Shared Image Gallery (SIG)
After image creation:

Images are published to SIG.

Versions and replicas managed here.

Used across Subscriptions or Regions (replication can be configured).

💻 VM / VMSS Deployments
Images from the SIG are used to:

Deploy into Azure Virtual Machines (individual or scale sets)

Often automated within the same pipeline

🔐 Azure Active Directory & RBAC
Controls access to subscriptions, image builder permissions, DevOps agents.

Roles shown include contributors, image publisher, etc.

🛡️ Security Review Layer (CADA / Security Team)
Reviews compliance, hardening, and image integrity.

May include integration with Azure Security Center or Defender for Cloud.

Optional: Azure Policy or Custom Initiative to validate configuration baseline.

🌐 Internet & Internal Repo Connections
Internet Access (optional for package downloads).

Internal Repositories (e.g., private Artifactory or GitHub Enterprise) shown with dotted lines, indicating optional external dependencies.


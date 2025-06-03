1. Azure DevOps
Acts as the orchestrator.

Triggers the image creation pipeline based on events (e.g., a new build or scheduled process).

Starts the process by calling internal repositories and deploying to the Azure environment.

🔷 2. Internal Repo Connectors
Repositories for scripts, tools, and configurations.

Could be Git, Artifactory, or any internal SCM system.

These resources are fetched by the image builder process.

🔷 3. Azure Image Builder
Core service that assembles and customizes the VM image.

Pulls artifacts from the internal repos.

Uses templates to install software, apply patches, and configure settings.

🔷 4. Azure Blob Storage (Staging Area)
Temporary storage for base images and build outputs.

Can also be used to store logs or intermediary steps.

Acts as the "Drop-Off" where Azure Image Builder stages image assets.

🔷 5. VM / Workstation Deployment
Final custom images are deployed to target machines.

Could be VMs, developer workstations, test environments, etc.

🔷 6. Azure Subscription / Dev Test Environment
Represents the deployment environment.

Where the image is built and validated before broader deployment.

Can include resource groups and supporting infra (networking, storage, etc.).

🔷 7. Shared Image Gallery (SIG)
Central repository to store and manage custom images.

Supports versioning, replication across regions, and image lifecycle management.

🔷 8. Azure Active Directory
Handles identity and access management.

Used to validate permissions for users and services in the pipeline.

🔷 9. Role-Based Access Control (RBAC)
Governs who can access and deploy the images.

Enforces secure, policy-driven access to SIG and VMs.

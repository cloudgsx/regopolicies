Description:
As a DevOps/Platform Engineering team, we need to refactor our AFT (Account Factory for Terraform) customizations repository to improve modularity, deployment flexibility, and state management.
Business Value:

Enable independent deployment of components without affecting the entire infrastructure
Reduce blast radius of changes and deployments
Improve deployment speed and CI/CD pipeline efficiency
Better organize infrastructure code for maintainability and scalability

Current State:

AFT customizations are in a monolithic repository structure
Components are tightly coupled in a single Terraform state
Deployments affect multiple resources unnecessarily
Environment variable management is unclear or centralized

Desired State:

Components are logically separated into individual repositories or modules
Each component has its own Terraform state for independent deployment
Clear environment variable files per component/environment
Well-defined dependencies between components


Acceptance Criteria:
✓ Conduct analysis of current AFT customizations repository and document:

All existing components and their dependencies
Current Terraform state structure
Existing environment variables and their usage

✓ Create a refactoring proposal document that identifies:

Components that can be isolated into separate repos/modules
Recommended Terraform state split strategy
New repository structure or module organization
Migration path and risks

✓ Define environment variable file structure:

Create standardized .tfvars or .env file templates
Document naming conventions (e.g., dev.tfvars, prod.tfvars)
Define where env files will be stored and how they'll be managed

✓ Create a prioritized list of components for isolation with:

Complexity assessment (low/medium/high)
Dependencies mapped
Recommended deployment order

✓ Document deployment strategy:

How individual components will be deployed
CI/CD pipeline changes required
State management approach (separate backends, workspaces, etc.)


Technical Tasks:

Analysis Phase

Inventory all resources in current AFT customizations
Map dependencies between components
Identify shared resources vs. isolated resources
Document current state file structure


Design Phase

Design new repository/module structure
Define Terraform backend configuration per component
Create environment variable file templates
Define module interfaces and outputs


Documentation Phase

Create refactoring runbook
Document new deployment procedures
Create architecture diagrams showing new structure
Define rollback procedures




Definition of Done:

 Analysis document completed and reviewed by team
 Refactoring proposal approved by tech lead/architect
 Environment variable file structure defined and documented
 Component isolation plan created with priorities
 Migration risks identified and mitigation strategies documented
 New repository/module structure documented with diagrams
 Deployment strategy documented and approved

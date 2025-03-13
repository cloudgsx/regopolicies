AC1: Management Group and Subscription Configuration

Given that input files (tfvars) contain defined values for management groups and subscriptions in Organization L1 Landing Zone,
When the landing zone template is executed in CORP,
Then the system should create the required management groups and subscriptions according to the defined configurations.

AC2: Role-Based Access Control (RBAC) Assignments

Given that SPN details required by IAM for L1 Landing Zone are defined in the input files,
When the landing zone template is executed,
Then the required role-based access (RBAC) permissions should be assigned to the SPN dedicated for IAM L1 Landing Zone per environment.

AC3: Infrastructure Deployment via Defined Configurations

Given that input files (tfvars) for CORP lanes are clearly defined within the landing zone,
When the landing zone template is executed,
Then the infrastructure should be provisioned as per the defined configurations without requiring manual modifications.

AC4: Removal of Jenkins Scope & Clarification on Pipeline Integration

Given that the landing zone template is updated to support required integration components,
When the landing zone template is executed,
Then it should ensure that all necessary configurations are applied to support the infrastructure buildout.

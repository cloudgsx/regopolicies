AC1: Network Configuration Validation
Given that the CORP build-out plan for network configuration is provided by the networking team,
When the tfvars (input files) for CORP lanes in the ConnHub L1 Landing Zone template are updated,
Then the system should validate that all networking components are configured correctly and match the build-out plan, including the hub/infra virtual network and ExpressRoute circuit ID.

AC2: Deployment of Essential Platform Resources
Given that the ConnHub L1 Landing Zone template provisions essential platform resources,
When the template is executed,
Then it should provision all required components, including hub and infra resource groups, virtual networks, subnets, NSGs, and private DNS configurations, ensuring compliance with connectivity and security policies.

AC3: Infrastructure Deployment via Defined Configurations
Given that input files (tfvars) for CORP lanes are clearly defined in the landing zone,
When the landing zone template is executed,
Then the infrastructure should be provisioned as per the defined configurations without requiring manual modifications.

AC4: Removal of Jenkins Scope & Clarification on Pipeline Integration
Given that the landing zone template is updated to support required integration components,
When the template is executed,
Then it should ensure that all necessary configurations are applied to support the infrastructure buildout.

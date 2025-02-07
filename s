1. External Identity & Access Submission (Summary)
Purpose: The document outlines Service Principal Names (SPNs) for identity and access management in Azure.
Main SPNs:
Sp_Platform_Admin (Root and per environment) - Grants full access and allows role assignments in Azure RBAC.
Sp_Platform_RBAC - Controls User Access Administration and Reader roles.
Sp_Platform_Lock - Provides the ability to lock Azure resources to prevent accidental deletions.
Sp_71148_Platform and Sp_71148_User - Manage application infrastructure components and test environments.
Insights:
The RBAC structure is well-defined, ensuring clear separation of roles between platform and application administrators.
The Platform Lock feature is a good security measure against unintentional changes.
The use of separate SPNs for different environments (Dev, UAT, Prod) indicates a strong focus on environment segregation and compliance.
2. Landing Zone Permissions Model
Depicts hierarchy for Azure resource access, including:
High-level administrators: SP_Platform_Admin for organization-wide access.
Platform IAM roles: SP_Platform_RBAC handles identity roles.
Application roles: SP_{AIT}Platform and SP{AIT}_User for managing app-level permissions.
Insights:
Well-structured role assignment model:
Top-down privilege control ensures security.
Separation between platform and user-level IAM roles minimizes risk.
Good IAM governance strategy, allowing controlled delegation of access to different teams.
3. ECP Azure Platform Environment (High-Level Design)
Shows the organizational hierarchy for Azure Landing Zones.
Management groups such as mg-corp-ecp have multiple sub-management groups, ensuring clear workload separation.
Logging and monitoring components are emphasized for security and compliance.
Insights:
Hierarchical management approach aligns with Azure best practices.
Separate landing zones for applications and infrastructure improve security.
Incorporation of monitoring and logging suggests a strong focus on auditability and governance.
4. Conceptual Diagram - BofA Azure Cloud
Depicts the cloud network structure, authentication, and API management.
User authentication via OAuth 2.0, integrated with Azure API Management.
Network security zones include:
External Zone (internet-facing)
Application Proxy
Internal Secure Zones
Bank-owned network infrastructure with co-location data centers.
Insights:
Strong security measures with authentication and controlled network zones.
Proper use of API gateways and proxies enhances application security.
Integration of bank-owned infrastructure with Azure provides redundancy and resilience.
Overall Recommendations
Implement Least Privilege Access: Ensure that each SPN has only the required permissions.
Automate Role Assignments: Consider using Azure Policy and Terraform for managing IAM roles efficiently.
Continuous Monitoring: Utilize Azure Security Center and SIEM tools to detect unauthorized access.
Periodic Reviews: Conduct quarterly access reviews to remove unused or excessive privileges.
Security Hardening for API Management: Introduce conditional access policies to prevent unauthorized API calls.




For your presentation, your team could ask engaging and insightful questions that encourage discussion, validate security measures, and explore areas for improvement. Here are some key questions categorized by topic:

1. Identity & Access Management (IAM)
How do we ensure least privilege access across different environments (Dev, UAT, Prod)?
How are Service Principal Names (SPNs) managed and rotated to prevent unauthorized access?
What mechanisms are in place to detect and prevent privilege escalation attacks?
How frequently are role assignments reviewed and audited for compliance?
Are there automated processes for onboarding/offboarding service principals?
2. Security & Compliance
How do we monitor and log access to critical resources?
Are there any real-time alerts for unauthorized access attempts?
How does the Platform Lock mechanism work in case of an emergency rollback?
What incident response plans exist if an SPN is compromised?
Are we using Azure Managed Identities to reduce credential exposure?
3. Cloud Architecture & Landing Zones
Why did we choose this hierarchical management structure for Azure resources?
How do we ensure network isolation between different landing zones?
What are the security boundaries between infrastructure and application teams?
How do we handle cross-subscription access for shared services?
What are the scaling limitations of our current landing zone design?
4. Automation & Governance
Are there Terraform or Infrastructure-as-Code (IaC) policies enforcing access control rules?
How do we handle role-based access control (RBAC) changes efficiently?
How does Azure Policy help enforce governance across subscriptions?
What is the process for requesting new SPNs? Is it automated?
How do we ensure cost management and resource optimization within the landing zones?
5. API & Network Security
How do we protect APIs from unauthorized access in the Azure environment?
What network security zones are in place to prevent lateral movement?
How do we manage secrets and credentials securely?
Are there rate limits or WAF (Web Application Firewall) rules for exposed APIs?
How does the Application Proxy layer improve security?
6. Risk & Future Improvements
What are the biggest security risks in our current architecture?
How do we plan to scale this Azure Landing Zone model in the future?
What tools are we using for continuous monitoring and security analytics?
How does this design compare to industry best practices?
Are there upcoming regulatory requirements that might impact our access policies?

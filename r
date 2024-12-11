Title:
Update Storage-Container Module for Version Bump and Control Evidencing

Description:
As a DevOps Engineer,
I want to update the storage-container module to bump its version for the business use case of control evidencing,
so that the latest horizon library is utilized, and all related landing zone modules and documentation are updated.

Acceptance Criteria:

AC1: Publish the storage-container module with the provided instructions.
AC2: Update tf_azr_lz_app_l2 landing zone to upgrade the storage-container module version.
AC3: Update tf_azr_lz_app_l3 landing zone to upgrade the storage-container module version.
AC4: Ensure the relevant documentation is updated, including:
Design document changes (as applicable).
Repository README file updates (as applicable).
Updates or creation of Confluence pages for tracking (as applicable).
Definition of Ready (DoR):

Dependencies and impacted items identified.
Required tools, resources, and permissions confirmed.
Testing environment prepared and ready for module updates.
Definition of Done (DoD):

Updated storage-container module version is published successfully.
Jenkins file is updated for module version and CI/CD repository configurations.
Landing zones tf_azr_lz_app_l2 and tf_azr_lz_app_l3 are updated and validated with the new module version.
Documentation (design documents, README files, Confluence pages) is reviewed and updated.
Peer reviews and required approvals are completed.
Tasks:

Update the storage-container module version.
Document version history and updates in the README file.
Update Jenkins files for the new module version and CI/CD repository configuration.
Update tf_azr_lz_app_l2 and tf_azr_lz_app_l3 landing zones to reflect the new version.
Validate changes in the testing environment.
Update and review all related documentation, including design documents and Confluence pages.
Dependencies:

Access to the latest horizon library.
Permissions to update Jenkins configurations and CI/CD pipelines.
Risks:

Incomplete or incorrect landing zone updates could lead to functionality issues.
Delayed documentation updates could result in misaligned processes.
Deliverables:

Updated storage-container module with the new version.
Updated Jenkins files for CI/CD processes.
Updated landing zones (tf_azr_lz_app_l2 and tf_azr_lz_app_l3) validated for production readiness.
Documentation, including design documents, README file, and Confluence pages, updated and reviewed.

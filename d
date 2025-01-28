Jira Story: Enhancement and Issue Fixes in IAC Pipeline

Project: [Your Project Name]
Issue Type: Story
Priority: High
Reporter: [Your Name]
Assignee: [Relevant Team/Individual]
Labels: DevOps, Jenkins, XLR, IAC-Pipeline

Summary:
Enhancements and issue fixes required in the IAC pipeline related to Jenkins builds, XLR triggers, packaging, and execution errors.

Description:
Based on discussions with Ashfaq and Aajaneyulu, the following issues and enhancement requests were identified in the IAC pipeline:

New Feature Branch Trigger Issue:

Currently, when a feature branch is created from develop, Jenkins Build (with tfe and XLR) is automatically triggered, causing unnecessary executions.
Expected Fix: Prevent triggering of new branches unless explicitly required.
Application Bit Bucket Contents Issue:

JSON and .tpl files included in Bit Bucket but not packaged, causing build failures.
Expected Fix: Provide a configuration file to allow developers to specify what needs to be packaged or skipped.
Folder Structure Support in ReleaseConfig.json:

The current configuration supports only one file per environment folder.
Example: If UAT requires multiple AIT files, it fails.
Expected Fix: Support folder structures within ReleaseConfig.json.
Unnecessary XLR Trigger on Feature Branch Push:

Every push in a feature branch triggers XLR execution, creating unnecessary overhead.
Expected Fix: Implement logic to skip XLR triggering on each step unless explicitly needed.
Lack of Error Messages on Build Failure Due to XLR Trials:

If a Jenkins build fails due to an existing XLR trial not being aborted, no clear error is displayed in the Jenkins console.
Expected Fix: Display a clear message indicating the reason for failure.
Failure in getHost Section in XLR Builds:

In XLR build trials, the getHost section frequently fails, preventing builds from proceeding.
Expected Fix: Investigate and resolve the root cause of these failures.
Re-Try Option in XLR Does Not Consider Previous Build Status:

If a previous build fails in plan/apply stages, XLR does not track this properly.
Expected Fix: Ensure retry accounts for past failures before execution.
XLR Failure Handling in Execution Flow:

If XLR fails during a build stage, the workflow continues instead of stopping.
Expected Fix: The build should be aborted if XLR fails at any stage.
Sync Issues in XLR UI Changes:

Changes like discarding a run in the UI are not reflected in XLR.
Expected Fix: Ensure UI actions sync correctly with XLR.
Acceptance Criteria:
Feature branch creation should not auto-trigger builds unless configured.
Configuration file should allow exclusion/inclusion of JSON and .tpl files.
ReleaseConfig.json should support multiple files per environment folder.
XLR should not be triggered on every feature branch push.
Proper error messages should appear for failed builds due to XLR trials.
getHost failures in XLR should not block builds.
Re-try in XLR should track previous build failures correctly.
XLR failures should halt execution rather than continuing.
UI changes in XLR should sync with the backend system.
Attachments:
[Attach any relevant logs, screenshots, or references]

Sprint: [Specify the Sprint or Milestone]
Story Points: [Estimate effort required, e.g., 8, 13]





Estimated Timelines (2-Week Sprints)
Task	Estimated Effort	Dependencies	Sprint
Prevent Auto-Trigger on Feature Branch Creation	2-3 days	Requires Jenkins pipeline changes	Sprint 1
Configuration for Skipping/Packaging JSON & TPL Files	3-4 days	Dev team needs to implement parsing logic	Sprint 1
Support Folder Structure in ReleaseConfig.json	4-5 days	Code changes + testing	Sprint 1
Skip XLR Trigger on Each Push to Feature Branch	3-4 days	Changes in XLR triggering logic	Sprint 2
Improve Error Message for XLR Trial Abortion in Jenkins	2-3 days	Requires Jenkins-XLR integration fixes	Sprint 2
Fix getHost Failures in XLR Builds	5-6 days	Root cause analysis + fix	Sprint 2
Ensure Retry in XLR Checks Previous Build Status	4-5 days	Logic update in XLR execution	Sprint 3
Abort Workflow if XLR Fails During Build	3-4 days	Modify execution flow	Sprint 3
Sync UI Changes (Run Discard) in XLR	4-5 days	Backend-XLR synchronization fix	Sprint 3
Total Estimated Time:
3 Sprints (~6 Weeks)
Sprint 1: Core fixes in Jenkins, configuration, and release file structure.
Sprint 2: XLR optimizations and error handling.
Sprint 3: Retry mechanism, UI sync, and final improvements.
Additional Considerations:
Testing & Debugging: Add 1-2 weeks of QA/testing before deployment.
Staging & Release: Deploy in a controlled environment, monitor, and release gradually.
Realistic Completion Date: 8-10 weeks (including testing and deployment)
Would you like a more detailed breakdown for tracking?

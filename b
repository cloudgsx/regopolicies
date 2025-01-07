Branching Strategy
1. Main Branches
main (or master):

Represents the production-ready code.
Should always be stable and deployable.
Protected branch: direct commits are not allowed; only pull requests (PRs) from other branches are merged here.
develop:

Represents the latest development version of the code.
Serves as an integration branch for feature branches.
Periodically merged into main after QA and approvals.
2. Supporting Branches
These branches have specific purposes and limited lifespans.

Feature Branches:

Naming convention: feature/feature-name.
Used for developing specific features or tasks.
Branches off: develop.
Merges into: develop via PR.
Delete after merge.
Bugfix Branches:

Naming convention: bugfix/bug-description.
Used for fixing bugs in the develop branch.
Branches off: develop.
Merges into: develop via PR.
Delete after merge.
Hotfix Branches:

Naming convention: hotfix/hotfix-description.
Used for critical fixes to the main branch.
Branches off: main.
Merges into: main and develop via PR.
Delete after merge.
Release Branches:

Naming convention: release/version-number.
Used to prepare for a production release (final testing, documentation updates).
Branches off: develop.
Merges into: main and develop via PR.
Delete after merge.
3. Workflow
Feature Development:

Developer creates a feature/ branch from develop.
Code is developed, committed, and pushed.
Pull Request is created to merge the feature branch into develop.
Review, approval, and merge.
Bug Fixing:

If the bug is in development: Create a bugfix/ branch from develop.
If the bug is in production: Create a hotfix/ branch from main.
Releases:

When develop is feature-complete, create a release/ branch.
Perform testing and fix issues in the release/ branch.
Merge the release/ branch into both main and develop.
Production Issues:

For urgent production issues, create a hotfix/ branch from main.
Fix the issue and merge the hotfix/ branch into both main and develop.

Summary of the story (what it is, why it matters)

Problem
When a Terraform change creates a new S3 bucket and configures S3 → SNS object notifications using an existing SNS topic, the Terraform module/build logic can end up overwriting the SNS topic policy (instead of safely extending it). That can unintentionally remove existing statements and break other integrations.

Goal
Add defensive guardrails so that whenever this risky pattern is detected, engineers get a clear warning in the Terraform plan / build output.

Acceptance Criteria (as shown)

AC: Verify warning message is printed to build output

Steps:

Create a feature branch in account-customizations that creates a new S3 bucket and references an existing SNS topic for object notifications

Run a plan-only build against the branch

Confirm warning appears in Terraform plan output

Notes from description

Preferred implementation path: OPA (Open Policy Agent) in the pipeline

If OPA isn’t feasible, still implement the warning behavior another way

Attach a copy of a Terraform plan from the “offending run” as reference

This change implies additional testing to ensure notifications still work (since policies are involved)

2) Plain-English translation (for non-engineers / stakeholders)

When we hook up a new S3 bucket to send event notifications to a topic that already exists, Terraform sometimes rewrites the topic’s permissions. That rewrite can accidentally delete permissions other systems need. We’re adding a safeguard so that, if someone makes this kind of change, the build will print a warning telling them they must double-check and test notifications to make sure nothing was broken.

3) Recommended implementation approach (best → fallback)
Option A (recommended): OPA policy that inspects Terraform plan JSON and prints a warning

Why this is best

Doesn’t rely on Terraform “warning” features (which vary by version)

Centralized and consistent across repos/teams

Easy to tune: “warn” vs “fail”

Can include rich context (bucket, topic ARN, resource address)

High-level logic

In the plan-only build, generate plan JSON (terraform show -json plan.out)

OPA policy evaluates plan JSON looking for:

an S3 notification config targeting SNS (often aws_s3_bucket_notification or a module that produces it)

an SNS topic ARN that appears to be pre-existing (heuristics below)

and/or an SNS topic policy resource that is being set in a way that could replace an existing policy

Heuristics for “existing SNS topic”
You likely won’t know for sure from plan JSON alone, but you can get very close:

If the SNS topic is not created in this plan (aws_sns_topic absent from planned resources) and the bucket notification references an SNS ARN, treat as “existing.”

If the ARN is passed via variable / data source / remote state, treat as “existing.”

Warning text (example)

WARNING: S3 bucket notification is configured to publish to an existing SNS topic. The S3 module may overwrite the topic policy. Confirm SNS topic policy remains correct and run an end-to-end notification test.

Deliverables

OPA rule (Rego) + unit tests with sample plan JSON

Pipeline config change to surface this as a warning (not necessarily a failure)

Option B: Terraform-native guardrails (only if you can’t do OPA)

Terraform doesn’t have a universally consistent “print warning during plan” mechanism across all versions, but you can approximate with:

precondition/postcondition messages (often fail the plan/apply, which may be too harsh)

a null_resource + local-exec echo (not great, noisy, and sometimes suppressed)

module design changes (best practice), but that’s slightly different than “print warning”

If the Jira story is strict about “warning in plan output” without failing, OPA is the cleanest.

Option C: Fix the root cause (recommended as follow-up even if you do OPA)

Even if you warn, it’s still good to make the module safer:

Avoid replacing full SNS topic policy; instead merge required statements into existing policy (or require passing in an existing policy doc to merge with).

Add a module flag like:

manage_sns_topic_policy = false when topic is external

or additional_sns_topic_policy_statements to append safely

Document required statement(s) for S3 publish permissions

OPA warning + module hardening is the ideal combo.

4) Improved Acceptance Criteria (stronger, less ambiguous)

Here’s an upgraded AC set you can paste into Jira:

AC1 – Warning triggers

When a plan includes S3 bucket notifications targeting an SNS topic ARN not created in the same plan, the build output includes a warning.

AC2 – Warning content

Warning includes at least:

bucket identifier (name or resource address)

SNS topic ARN (or resource address)

explicit risk: “topic policy may be overwritten”

required action: “validate topic policy and run notification test”

AC3 – No false positives

Warning does not trigger when:

SNS topic is created in the same plan (topic is not “existing”), or

a module setting indicates the topic policy is not being managed/overwritten (if implemented)

AC4 – Evidence

Attach plan output (or link to build log) showing the warning firing for the test branch.

5) Test plan (OPA + integration)
Unit tests (fast, deterministic)

Create a small set of Terraform plan JSON fixtures:

S3 notification → existing SNS topic ARN (should warn)

S3 notification → SNS topic created in same plan (should NOT warn)

No S3 notification resources (should NOT warn)

Multiple buckets / topics (warns for each match, or aggregates into one warning)

Run OPA tests in CI (or locally) against those fixtures.

Integration test (matches your Jira steps)

Create feature branch in account-customizations:

new S3 bucket

configure object notifications to an existing SNS topic

Run plan-only pipeline

Confirm warning appears in the plan/build output

(Optional but recommended) Apply in a sandbox and confirm:

topic policy still includes needed statements

S3 event reaches SNS (end-to-end test)

6) Risks / edge cases to call out

Plan JSON may not clearly show “existing” vs “new” in all module patterns (variables, remote state, data sources). Use sensible heuristics and err on warning rather than silence.

Policy overwrite might happen even if the topic is created in-plan if multiple modules manage policy independently. (If you see multiple aws_sns_topic_policy writers, that’s a smell.)

Multiple topics / multiple buckets: warning should avoid spam (either aggregate, or cap output).

False positives: Some teams may intentionally want the module to fully manage policy. If so, include an allowlist/annotation mechanism (e.g., tag/label/variable) to suppress warning explicitly.

Build output visibility: Ensure the warning lands somewhere engineers actually see (pipeline summary, plan logs, etc.).

7) Draft Jira comment (status/update)

You can drop something like this into the ticket:

Proposed implementation: add an OPA policy check against Terraform plan JSON in plan-only builds. The policy will detect S3 bucket notification configs targeting an SNS topic ARN that is not created in the same plan (treated as “existing topic”) and print a warning that the S3 module may overwrite the SNS topic policy.

Test approach: add OPA unit tests with plan JSON fixtures + integration via feature branch in account-customizations. Attach plan output showing the warning.

Optional follow-up: module hardening to merge policy statements or provide a manage_policy flag to reduce risk long-term.

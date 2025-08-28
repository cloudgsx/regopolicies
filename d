1) One saved filter = single source of truth

Create & share a saved filter (owner: Release Eng; shared with SRE group):

project = ECPAMS
AND fixVersion = ECP.2025.08.27.AxiaMedPRODDEPLOY


Variants SRE will use during the window:

Open only:
... AND resolution = Unresolved

In flight (not done):
... AND statusCategory != Done

Blockers only:
... AND priority in (Highest, High) AND resolution = Unresolved

2) SRE release dashboard (pulls only from that filter)

Add these JIRA gadgets, all pointed at the saved filter above:

Filter Results (columns: Key, Summary, Assignee, Status, Priority, Fix Version, Labels, Environment)

Two-Dimensional Statistics — Status × Assignee (shows who owns what, by state)

Issue Statistics — by Priority (quick risk view)

Created vs Resolved Chart — scope change during the window

Version Report / Release Burndown (if your board uses the version)

Optional: Average Age for unresolved items (spot aging risks)

The “release table” you mentioned should be this Filter Results gadget, pointed at the same saved filter, so it always matches the embedded query.

3) Notifications for live changes (no repos)

Two light JIRA automation rules (built-in):

Rule A — Status change pings SRE

Trigger: Issue transitioned

Condition: fixVersion = ECP.2025.08.27.AxiaMedPRODDEPLOY

Action: Post to #sre-release (or email SRE) with key, old→new status, assignee.

Rule B — New blocker alert

Trigger: Issue created or priority changed

Condition: same fixVersion AND priority in (Highest, High) AND resolution = Unresolved

Action: Notify SRE + add comment “Flagged as release blocker.”

4) Simple run-book for SRE during the window

T-24h: Run Open only filter; chase any “Unassigned” or “To Do”.

Start of window: Keep dashboard open; Two-Dim chart is the live board for hand-offs.

Hourly check: Review the Filter Results list sorted by Updated to catch stalls.

Pre-cutover: Ensure In flight filter is empty for risky components.

Post-deploy: Switch to statusCategory = Done to confirm closure; export list for notes.

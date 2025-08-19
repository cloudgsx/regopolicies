pulling Jira stories (issues) with certain metadata (e.g., story number, owner, status, etc.) into a Confluence release page. This is a very common workflow, and there are several ways to do it depending on your setup and how automated you want it to be.

Option 1: Use Jira Macros in Confluence (built-in)

Confluence has a Jira Issues Macro that lets you embed live Jira queries into a page.

Edit your Confluence page.

Type /Jira (or {jira} if using wiki markup).

Select Jira Issues.

Configure a filter, JQL, or paste a Jira filter link.

Example JQL:

project = MYPROJ AND fixVersion = "Release 1.2" AND labels = release-123


Choose which columns to display (story key, summary, assignee/owner, status, etc.).

✅ Benefit: Auto-updates, no manual copy-paste.
❌ Limitation: Formatting might be limited compared to a manually curated table.

Option 2: Saved Jira Filters + Confluence Integration

In Jira, create and save a filter:

labels = release-123 AND issuetype = Story


Save & share the filter.

In Confluence, use the Jira Filter Macro to insert the filter directly.

Choose display format: table, list, or chart.

Option 3: Export from Jira → Import into Confluence Table

If you want a one-time snapshot (not live updates):

Run a Jira search with your criteria.

Export as CSV/Excel.

Copy/paste into your Confluence page (or use Confluence’s table import).

Optionally format the table (story, owner, priority, etc.).

✅ Benefit: You can heavily customize.
❌ Limitation: Manual refresh.

Option 4: API + Automation

If you need more customization:

Use the Jira REST API to query stories by label/fixVersion.

GET /rest/api/3/search?jql=labels=release-123


Parse fields: key, fields.assignee.displayName, fields.summary, etc.

Use a script (Python, Node, etc.) to generate a markdown/Confluence wiki table.

Push it into Confluence via Confluence REST API.

✅ Benefit: Full control & automation.
❌ Limitation: Requires dev effort + API access.

⚡ Best quick win for you:
If you just want a live Confluence release page → use Jira Issues Macro with a JQL filter that targets your release stories (by label, fixVersion, or sprint).

If you want a one-time static release notes table → export from Jira and paste into Confluence.

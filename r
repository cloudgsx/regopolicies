Goal:
Improve visibility and tracking for requestors of AWS Platform-related Jira requests.

🔧 1. Intake Workflow
🔹 Request Submission
Clients submit requests via:

Email to DG ECP AWS Platform Requests

(Optional/Future) Confluence or SharePoint intake portal

We are exploring replacing email with a Jira form to improve structure and automation. Backend fields can help automate categorization.

🔹 Ticket Creation
All new requests go into a Toil Gate Jira Project (TPK) queue.

Consider creating templates for different request types.

Toil Gate creates Jira tickets weekly if needed.

🔹 Categorization & Tagging
Review intake queue and assign:

Workload category

Priority (H/M/L)

SLA level

Automatically add requester as watcher on ticket

Allow submitters to track ticket progress

🔹 Processing
Tickets are reviewed and groomed in backlog

Assign to appropriate team (e.g., move to ECPAWS project if needed)

Tag for next release cycle

🔹 Optional Workflow Branches
Duplicate? → Close or merge with existing ticket

High Priority? → Route faster, tag with H/P

🔹 Visual Process Flow

Dashboards
Initial Intake Dashboard – For triage team to see new requests

ECPAWS Intake Dashboards – One per workload (HPS, BARS, CATS) or one dashboard with filters

Dashboards should include:

Number of tickets

SLA metrics

Graphs per team or workload

Release tagging and progress status

Use tags and labels for filtering and visibility

Publish dashboards on:
Bank of America Hybrid Multi-Cloud Platforms – Enterprise Multi-Cloud Services – Horizon/Docs

🔁 3. Request Automation & Communication
Notifications: Requester gets ticket number and can track progress

Auto-Reply: If email is used, auto-response confirms receipt and links to Jira

Example: “Thanks for your request. You can track status here: [Jira link]”

Erica may assist with triaging and directing clients to documentation before intake

🧹 4. Dealing with Duplicate Requests
Jira form should include “Related Ticket” or “Duplicate of?” field

Train triage team to detect duplicates during grooming

Optionally notify requester of merge/closure with rationale

🆕 5. New Client Onboarding Process
Create and submit Jira ticket via:

[GT Cloud Front Door Instructions.pptx]

[APSE Cloud Front Door.pptx]

Attach intake questionnaire

Outputs:

SLA: 3–4 business days

Workload and classification

Priority (H/M/L)

Cloud Use Case Disposition

Design Routing

💬 6. Comments & Considerations
SPK vs. TPK ticket linking (e.g., tracking cross-board requests)

Use Jira Issue Collector or form with mandatory fields

Confluence-based request page may feed directly into Jira board

Jocelyn recommends multiple Jira collectors repurposed for different workflows

Include a process flow UI in Confluence for better user understanding


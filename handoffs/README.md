# Engineer & Service Handoff Directory (`handoffs/`)

> **MANDATORY PROCEDURE:**
> When an engineer (or their AI) finishes implementing a module, infrastructure service, playbook, or pipeline, they **MUST create a folder under this directory** named after their name and the service completed:
>
> `handoffs/<coworker-name>/<service-or-component-name>/`
>
> Inside this folder, include a `HANDOFF_REPORT.md` and any verification artifacts (screenshots, command logs, terraform plan outputs, test reports).

---

## Folder Structure Example

```
handoffs/
├── README.md                               # This instruction file
│
├── john-doe/
│   ├── vpc-and-rds-terraform/
│   │   ├── HANDOFF_REPORT.md              # Detailed documentation of what John + AI did
│   │   ├── terraform-plan.log             # Sanitized plan output
│   │   └── verification-results.txt       # Proof that connections passed
│   │
│   └── k8s-ansible-setup/
│       ├── HANDOFF_REPORT.md
│       └── playbook-execution.log
│
└── sarah-connor/
    └── inventory-service-helm/
        ├── HANDOFF_REPORT.md
        └── helm-dry-run-output.yaml
```

---

## Standard Template: `HANDOFF_REPORT.md`

Whenever you finish a service, copy this template into your new folder:

```markdown
# Handoff Report: <Service / Component Name>

- **Author / Engineer:** <Full Name>
- **AI Assistant Used:** <e.g. ChatGPT-4o, Claude 3.5 Sonnet, etc.>
- **Date Completed:** <YYYY-MM-DD>
- **Branch / PR Merged:** `<branch-name>` / `<PR-#>`

---

## 1. Executive Summary
Brief 2-3 sentence overview of what this service/component does and why it was built.

---

## 2. Resources & Files Created / Modified
List the specific files created in the repository:
- `terraform/modules/<service>/...`
- `ansible/roles/<role>/...`
- `helm/charts/<chart>/...`

---

## 3. How to Deploy / Run This Service
Provide step-by-step commands for the next person:
```bash
# Example
cd terraform/environments/dev
terraform init
terraform apply -target=module.<service_name>
```

---

## 4. Verification Evidence & Tests Passed
Explain how you verified this service works:
- [x] Linting / Syntax checks passed (`terraform fmt`, `ansible-lint`, etc.)
- [x] Dry run / Plan passed
- [x] Live deployment test passed against AWS / K8s

*Attach command logs or outputs below.*

---

## 5. Outputs & Information Needed by Other Services
List any endpoints, security group IDs, ARNs, or variables that subsequent services depend on:
- **Output 1:** `rds_endpoint = "apex-postgres.c123.us-east-1.rds.amazonaws.com:5432"`
- **Output 2:** `security_group_id = "sg-0123456789abcdef"`

---

## 6. Known Limitations or Next Steps
Any open questions, pending PRs, or tasks that need to be followed up.
```

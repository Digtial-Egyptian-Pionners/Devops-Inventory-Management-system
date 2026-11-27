# Apex Inventory — Complete DevOps Engineering & AI Collaboration Handbook

> **Notice:** This is the single, all-in-one authoritative document for the DevOps repository (`apex-inventory-devops`). Hand this file directly to your coworker and have any AI assistant read it before writing any code or infrastructure.

---

## Table of Contents
1. [Project Overview & Architectural Decisions](#1-project-overview--architectural-decisions)
2. [End-to-End Infrastructure Architecture](#2-end-to-end-infrastructure-architecture)
3. [DevOps Repository Directory Structure](#3-devops-repository-directory-structure)
4. [Tool Responsibilities & Separation of Concerns](#4-tool-responsibilities--separation-of-concerns)
5. [Network Topology & Security Matrix](#5-network-topology--security-matrix)
6. [Mandatory AI & Engineer Collaboration Rules](#6-mandatory-ai--engineer-collaboration-rules)
7. [The Living AI Activity Audit Log Specification](#7-the-living-ai-activity-audit-log-specification)
8. [The Service Handoff Protocol (`handoffs/<name>/<service>/`)](#8-the-service-handoff-protocol-handoffsnameservice)
9. [Copy-Paste AI System Prompt for Collaborators](#9-copy-paste-ai-system-prompt-for-collaborators)

---

## 1. Project Overview & Architectural Decisions

**Apex Inventory** is a multi-branch restaurant inventory management platform. The DevOps repository manages the cloud infrastructure, server configuration, container packaging, and CI/CD pipelines.

### Core Architectural Decisions:
1. **Frontend:** React SPA hosted in an **Amazon S3** private bucket and served globally via **AWS CloudFront** using Origin Access Control (OAC).
2. **Backend 1 (Inventory Management Service):** Java 21 / Spring Boot 3+ containerized service running inside a **self-managed Kubernetes cluster hosted directly on AWS EC2 instances** (not AWS EKS). Owns authentication, JWT (RS256), catalogue, branch stock, audit movements, reports, and transactional outbox.
3. **Backend 2 (Notification Management Service):** Serverless **AWS Lambda** attached to VPC subnets, invoked asynchronously by the Inventory outbox dispatcher, and queried by clients via **AWS API Gateway (HTTP API)**.
4. **Database:** **Amazon RDS PostgreSQL 16** hosted in private isolated subnets. Hosts two strictly independent logical databases:
   * `inventory_db` (owned by user `inventory_app`)
   * `notification_db` (owned by user `notification_app`)
   * **Rule:** No cross-database queries or foreign keys between them.
5. **Administration:** A **Bastion Host (Jumpbox) EC2** in the public subnet (accessed via AWS SSM Session Manager or secure SSH) for `kubectl` cluster operations and `psql` database maintenance.
6. **Observability:** **Prometheus & Grafana** running as pods inside the Kubernetes cluster on the EC2 worker nodes.

---

## 2. End-to-End Infrastructure Architecture

```
                                      [ Users / Web Browsers ]
                                                 │
                                                 ▼
                                     [ AWS CloudFront (CDN) ]
                                     ┌───────────┼───────────┐
                        Path: /*     │   /api/v1/*   │       │ /api/notifications/*
                                     ▼           │           ▼
                           [ S3 Static Bucket ]  │   [ AWS API Gateway (HTTP) ]
                          (React SPA via OAC)    │           │
                                                 │           ▼
                                                 │   [ Notification Lambda ]
                                                 │    (VPC-attached Lambda)
                                                 ▼           │
                                   [ Public AWS ALB ]        │
                                           │                 │
              ┌────────────────────────────┴─────────────┐   │
              │ AWS VPC (Private Subnets)                │   │
              │                                          │   │
              │  [ K8s EC2 Worker Nodes ]                │   │
              │   ├── NGINX Ingress (NodePort: 30080)    │   │
              │   ├── inventory-service Pods             │   │
              │   └── Prometheus & Grafana Pods          │   │
              │           │                              │   │
              └───────────┼──────────────────────────────┼───┘
                          │                              │
                          ▼                              ▼
                  ┌──────────────────────────────────────────────┐
                  │ Amazon RDS PostgreSQL 16                     │
                  │  - inventory_db                              │
                  │  - notification_db                           │
                  └──────────────────────────────────────────────┘
```

### Traffic & Data Flow Summary:
1. **Frontend Traffic:** CloudFront delivers static React assets from S3.
2. **Inventory API Calls (`/api/v1/*`):** CloudFront forwards requests directly to the Public **Application Load Balancer (ALB)**, which routes traffic to the EC2 Worker Nodes on the Ingress Controller's **NodePort** (`30080`/`30443`).
3. **Notification API Calls (`/api/notifications/*`):** CloudFront forwards requests to **API Gateway**, which invokes the **Notification Lambda**.
4. **Stock Events & Outbox:** When stock updates occur, `inventory-service` commits the update, audit movement, and outbox event atomically to `inventory_db`. The outbox dispatcher asynchronously invokes the Notification Lambda using the AWS SDK.
5. **Notification Storage:** The Lambda receives the event and writes in-app notifications into `notification_db`.

---

## 3. DevOps Repository Directory Structure

Every engineer and AI assistant working on the repository must follow this folder layout:

```
apex-inventory-devops/
├── .github/
│   ├── workflows/
│   │   ├── pr-lint-validate.yml        # Validates Terraform (fmt/validate), Ansible (lint), and Helm (lint)
│   │   ├── terraform-plan-apply.yml    # Terraform plan on PR, gated apply on main
│   │   ├── build-inventory-image.yml   # Builds & pushes Spring Boot Docker image to AWS ECR
│   │   └── deploy-helm.yml             # Deploys/upgrades Helm charts to K8s via Bastion runner
│   └── pull_request_template.md        # Standardized PR checklist
│
├── terraform/                          # Infrastructure as Code (AWS Cloud Resources)
│   ├── environments/
│   │   ├── dev/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── outputs.tf
│   │   └── prod/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── terraform.tfvars
│   │       └── outputs.tf
│   └── modules/
│       ├── vpc/                        # VPC, Subnets (Public, App, DB), NAT Gateway, Route Tables
│       ├── security_groups/            # ALB, Bastion, K8s Master/Workers, Lambda, and RDS rules
│       ├── s3_cloudfront/              # S3 SPA bucket, OAC, CloudFront edge routing
│       ├── rds/                        # RDS PostgreSQL 16, DB subnet group, parameter groups
│       ├── ec2_k8s/                    # EC2 instances for K8s Master & Worker nodes, IAM roles
│       ├── alb/                        # Public ALB, Target Groups for K8s NodePort (30080)
│       ├── bastion/                    # Bastion EC2 host, SSM instance profile, cloud-init
│       └── lambda_apigw/               # Notification Lambda in VPC, HTTP API Gateway v2
│
├── ansible/                            # OS Configuration & K8s Cluster Bootstrapping
│   ├── ansible.cfg
│   ├── inventory/
│   │   ├── aws_ec2.yml                 # Dynamic AWS EC2 inventory plugin
│   │   ├── dev.ini                     # Static inventory fallback
│   │   └── prod.ini
│   ├── group_vars/
│   │   ├── all.yml                     # Common variables (K8s version, containerd configs)
│   │   ├── k8s_masters.yml
│   │   ├── k8s_workers.yml
│   │   └── bastion.yml
│   ├── roles/
│   │   ├── common/                     # Updates, NTP, security hardening, AWS CLI
│   │   ├── containerd/                 # Installs containerd with systemd cgroup driver
│   │   ├── k8s_base/                   # Installs kubeadm, kubelet, kubectl
│   │   ├── k8s_master/                 # kubeadm init, installs CNI (Calico or Flannel)
│   │   ├── k8s_worker/                 # kubeadm join worker nodes to master
│   │   └── bastion/                    # Installs psql, kubectl, helm, fetches cluster kubeconfig
│   ├── playbooks/
│   │   ├── site.yml                    # Master playbook executing all roles in order
│   │   ├── setup-bastion.yml           # Prepares Bastion Host
│   │   └── bootstrap-cluster.yml       # Initializes and scales the K8s cluster
│   └── requirements.yml
│
├── helm/                               # Kubernetes Application Packaging
│   ├── charts/
│   │   └── inventory-service/          # Helm chart for Spring Boot inventory-service
│   │       ├── Chart.yaml
│   │       ├── values.yaml             # Base values
│   │       ├── values-dev.yaml
│   │       ├── values-prod.yaml
│   │       └── templates/
│   │           ├── deployment.yaml
│   │           ├── service.yaml
│   │           ├── ingress.yaml        # NGINX Ingress resource routing /api/v1/*
│   │           ├── hpa.yaml            # Horizontal Pod Autoscaler
│   │           ├── configmap.yaml      # Non-sensitive app config
│   │           └── secrets.yaml        # ExternalSecrets / SealedSecrets template
│   └── third-party/                    # Values files for upstream Helm charts
│       ├── nginx-ingress-values.yaml   # Configured for NodePort (30080/30443) targeting ALB
│       └── kube-prometheus-stack-values.yaml # Configured for Spring Boot actuator scraping
│
├── handoffs/                           # Dedicated folder for completed work per engineer & service
│   ├── README.md                       # Instructions and standard HANDOFF_REPORT.md template
│   └── <coworker-name>/                # e.g., john-doe/
│       └── <service-completed>/        # e.g., vpc-and-rds-terraform/
│           ├── HANDOFF_REPORT.md       # Exact description of what was done, tests, & how to run
│           └── verification-logs.txt   # Attached logs, plans, or test proofs
│
├── scripts/                            # Operational & Helper Scripts
│   ├── setup-local-tools.sh            # Helper script to install dev tools
│   ├── test-db-connection.sh           # Test script to run from Bastion against RDS
│   └── generate-kubeconfig.sh          # Fetches kubeconfig from Master to Bastion
│
├── docs/                               # Architecture, Runbooks & Diagrams
│   ├── ARCHITECTURE.md
│   └── RUNBOOK_DATABASE_BACKUPS.md
│
├── AI_ACTIVITY_AUDIT_LOG.md            # MANDATORY: Every AI run/edit logs who, what, when, model, & tests
├── DEVOPS_COLLABORATION.md             # Shared state, claims, and handoff log for engineers & AI
├── .gitignore
├── .editorconfig
└── README.md
```

---

## 4. Tool Responsibilities & Separation of Concerns

To prevent conflicting automation, the stack enforces strict tool boundaries:

| Tool | What It OWNS | What It MUST NOT Do |
| :--- | :--- | :--- |
| **Terraform** | AWS cloud resources (VPC, Subnets, EC2 nodes, Bastion, S3/CloudFront, RDS, ALB, Lambda, API Gateway, Security Groups, IAM). | **DO NOT** use `local-exec` to run Ansible, configure the OS, or bootstrap Kubernetes. |
| **Ansible** | OS-level configuration on EC2 instances (packages, `containerd`, `kubeadm`, CNI network, Bastion tools). | **DO NOT** create cloud resources like VPCs or RDS databases. |
| **Helm** | Kubernetes workloads (`inventory-service`, NGINX Ingress, Prometheus/Grafana, ConfigMaps, Secrets). | **DO NOT** manage EC2 hosts or cloud infrastructure. |
| **CI/CD** | Orchestrating linting, tests, container builds, and running Terraform/Ansible/Helm in sequence. | **DO NOT** store hardcoded plaintext secrets. |

---

## 5. Network Topology & Security Matrix

### 5.1 Subnet Architecture (Across 2 Availability Zones)
1. **Public Subnets (`10.0.1.0/24`, `10.0.2.0/24`):**
   * Connected to Internet Gateway.
   * Houses: Public ALB, Bastion Host EC2, and NAT Gateway(s).
2. **Private App Subnets (`10.0.10.0/24`, `10.0.20.0/24`):**
   * Default route points to NAT Gateway.
   * Houses: K8s Control Plane EC2s, K8s Worker EC2s, and Lambda VPC ENIs.
3. **Private Database Subnets (`10.0.30.0/24`, `10.0.40.0/24`):**
   * **Isolated:** No Internet Gateway or NAT Gateway routes.
   * Houses: Amazon RDS PostgreSQL 16 Subnet Group.

### 5.2 Security Groups Matrix

| Security Group | Inbound Rules | Outbound Rules |
| :--- | :--- | :--- |
| **`sg_alb`** (Public ALB) | • TCP 443 (HTTPS) from CloudFront IP prefix list (or `0.0.0.0/0`)<br>• TCP 80 (HTTP) redirect | • TCP NodePort (`30080`, `30443`) to `sg_k8s_workers` |
| **`sg_bastion`** (Bastion EC2) | • TCP 22 (SSH) from trusted admin IPs only (or empty if using SSM) | • All outbound to Private Subnets |
| **`sg_k8s_masters`** | • TCP 6443 (K8s API) from `sg_bastion` and `sg_k8s_workers`<br>• TCP 2379-2380 (etcd) from `sg_k8s_masters`<br>• TCP 22 from `sg_bastion` | • All outbound to `sg_k8s_workers` |
| **`sg_k8s_workers`** | • TCP NodePort (`30080`) from `sg_alb`<br>• TCP 10250 (Kubelet) from `sg_k8s_masters`<br>• Overlay CNI (Calico/Flannel) from `sg_k8s_workers` & `sg_k8s_masters`<br>• TCP 22 from `sg_bastion` | • TCP 5432 to `sg_rds`<br>• HTTPS 443 to NAT Gateway (ECR pulls, Lambda invoke) |
| **`sg_lambda`** (Notification) | • None (invoked internally via API Gateway & AWS SDK) | • TCP 5432 to `sg_rds`<br>• HTTPS 443 to VPC endpoints / NAT |
| **`sg_rds`** (PostgreSQL) | • TCP 5432 from `sg_k8s_workers`<br>• TCP 5432 from `sg_lambda`<br>• TCP 5432 from `sg_bastion` | • None required (isolated) |

---

## 6. Mandatory AI & Engineer Collaboration Rules

1. **Never Commit Directly to `main`:** Work exclusively on feature branches (`infra/<task>`, `config/<task>`, `helm/<task>`, `cicd/<task>`).
2. **Never Put Secrets in Git:** All passwords, tokens, and private keys must be stored in AWS Secrets Manager or SSM Parameter Store.
3. **Log Every Single Edit in `AI_ACTIVITY_AUDIT_LOG.md`:** See Section 7.
4. **Create a Service Handoff Folder upon Completion:** See Section 8.
5. **Run Linting Before Committing:**
   * Terraform: `terraform fmt -check` && `tflint`
   * Ansible: `ansible-lint`
   * Helm: `helm lint ./helm/charts/*`

---

## 7. The Living AI Activity Audit Log Specification

File location: `apex-inventory-devops/AI_ACTIVITY_AUDIT_LOG.md`

> **RULE:** Every time an engineer or an AI makes a code change, runs a test, or refactors a file, they **MUST append an entry to the top** of `AI_ACTIVITY_AUDIT_LOG.md`.

### Required Entry Template:
```markdown
### [YYYY-MM-DD HH:mm:ss UTC] — <Task Name / Short Summary>
- **Collaborator / Owner Name:** <Coworker's Full Name>
- **AI Agent / Model Used:** <e.g., ChatGPT-4o, Claude 3.5 Sonnet, Gemini 3.8 Flash, Cursor, etc.>
- **Branch / PR:** `<branch-name>` / `<PR-#>`
- **Files Modified / Created:**
  - `<file-path-1>`
  - `<file-path-2>`
- **Exact Actions & Changes Made:**
  - Bullet 1 detailing what was changed.
  - Bullet 2 detailing what was changed.
- **Verification Commands Executed & Output:**
  - Command: `<command>` | Result: `PASS (exit 0)` | Summary: `<details>`
- **Status:** `IN_PROGRESS` | `COMPLETED` | `BLOCKED`
- **Next Step / Handoff Note:** <Instructions for next collaborator>
```

---

## 8. The Service Handoff Protocol (`handoffs/<name>/<service>/`)

Whenever a contributor (or their AI) finishes a complete component (e.g. VPC, RDS, Ansible K8s setup, Helm chart), they must create a folder:

```
handoffs/<coworker-name>/<service-completed>/
```
*Example:* `handoffs/alex/vpc-and-rds-terraform/`

Inside this folder, they must provide:
1. `HANDOFF_REPORT.md` (using the template below).
2. Supporting evidence files: logs, sanitized plan outputs, or test results.

### `HANDOFF_REPORT.md` Template:
```markdown
# Handoff Report: <Service / Component Name>

- **Author / Engineer:** <Full Name>
- **AI Assistant Used:** <Model Name>
- **Date Completed:** <YYYY-MM-DD>
- **Branch / PR Merged:** `<branch-name>` / `<PR-#>`

## 1. Executive Summary
Brief summary of what this component provides.

## 2. Resources Created / Modified
- `terraform/modules/...`
- `ansible/roles/...`

## 3. How to Deploy / Run
```bash
cd terraform/environments/dev
terraform apply -target=module.<name>
```

## 4. Verification Evidence & Tests Passed
- [x] Linting / Syntax checks passed
- [x] Plan / Dry-run passed
- [x] Live smoke test passed

## 5. Outputs & Information Needed by Other Services
- `rds_endpoint = "..."`
- `security_group_id = "..."`

## 6. Known Limitations or Next Steps
```

---

## 9. Copy-Paste AI System Prompt for Collaborators

Give this exact prompt to any AI assistant (ChatGPT, Claude, Cursor, Copilot) being used on the DevOps repository:

```text
You are a Senior DevOps & Cloud Infrastructure Architect working on the 'apex-inventory-devops' repository.

Your task is to implement and maintain the infrastructure, configuration, and CI/CD for Apex Inventory.
Before writing any code:
1. Review the architecture, folder structure, and rules in the 'Complete DevOps Engineering & AI Collaboration Handbook'.
2. Strictly maintain separation of concerns:
   - Terraform for AWS cloud resources (VPC, Subnets, EC2 nodes, Bastion, S3/CloudFront, RDS, ALB, Lambda, Security Groups).
   - Ansible for OS configuration, containerd, kubeadm, and Bastion host setup.
   - Helm for Kubernetes application packaging (inventory-service, Ingress on NodePort 30080, Prometheus/Grafana).
   - GitHub Actions for CI/CD automation.
3. Every time you make an edit or run a command, you MUST log your actions, your AI model name, your human owner's name, files changed, and verification evidence in 'AI_ACTIVITY_AUDIT_LOG.md'.
4. Once you complete a service/milestone, create a handoff folder under 'handoffs/<owner-name>/<service>/' with a filled-out 'HANDOFF_REPORT.md'.
5. Never commit secrets to Git. Always use AWS Secrets Manager / SSM Parameter Store.
```

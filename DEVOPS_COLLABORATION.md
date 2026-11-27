# DevOps Collaboration & Handoff Log

> Claim your task here before editing any files. Never commit directly to `main` once feature development begins; use feature branches (`infra/*`, `config/*`, `helm/*`, `cicd/*`).

## 1. Active Task Claims
| Engineer / AI Agent | Task Description | Target Paths | Started At | Status |
|---|---|---|---|---|
| Project Owner / Antigravity | Terraform AWS foundation | `terraform/` | 2026-11-27 | COMPLETED |
| *Unclaimed* | Ansible K8s & Bastion setup | `ansible/` | — | PENDING |
| *Unclaimed* | Helm charts & monitoring | `helm/` | — | PENDING |
| *Unclaimed* | GitHub Actions CI/CD | `.github/workflows/` | — | PENDING |

## 2. Completed Milestones
| Date | Contributor | Branch | Commit | Scope / What Was Done | Verification Passed |
|---|---|---|---|---|---|
| 2026-11-27 | Project Owner / Antigravity | `main` | *Pending* | Built Free-Tier Terraform foundation (VPC, SGs, Bastion NAT, `t3.small` K8s EC2s, RDS `db.t3.micro`, Secrets Manager, ALB, Lambda+APIGW, S3+CloudFront, ECR) | `terraform apply` (59 resources), SSH/NAT/RDS 5432/IAM checks, `terraform destroy` (59 destroyed) |
| 2026-11-27 | Project Architect / Antigravity | `main` | Initial | Created DevOps repository structure, handbook, audit log, and handoff templates | Structure verified |

## 3. Known Blockers & Cross-Team Notes
- **Databases:** RDS PostgreSQL 16 hosts a single database (`inventory_db`) with two logically isolated schemas: `public` (Inventory Service) and `notification` (Notification Lambda), per ADR-010 (no cross-schema foreign keys). Secrets Manager stores credentials at `apex-inventory/dev/rds-credentials`.
- **Routing:** CloudFront routes `/*` to S3 (OAC), `/api/v1/*` to Public ALB → K8s NGINX Ingress (NodePort `30080`), and `/api/notifications/*` to API Gateway → Notification Lambda.
- **K8s Hosting:** Self-managed Kubernetes (`k3s` recommended on `t3.small` / ~1905 MB RAM) on private EC2s (not EKS); outbound internet routes through Bastion NAT (`t3.micro`), and Ansible connects via Bastion `ProxyJump` using `depi-task.pem`.

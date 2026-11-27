cd /mnt/d/Final-DEPI-Project/Devops-Inventory-Management-system

python3 - << 'EOF'
with open("AI_ACTIVITY_AUDIT_LOG.md", "r", encoding="utf-8") as f:
    content = f.read()

marker = "## Activity Log (Chronological — Newest on Top)\n"
new_entry = """## Activity Log (Chronological — Newest on Top)

### [2026-11-27 19:05:00 UTC] — Built Complete Ansible K8s Cluster & Bastion Configuration
- **Collaborator / Owner Name:** Ahmed Nabil (`@ahmedsiam1`)
- **AI Agent / Model Used:** Gemini
- **Branch / PR:** `config/ansible-k8s` / Pending PR
- **Files Modified / Created:**
  - `DEVOPS_COLLABORATION.md`
  - `ansible/ansible.cfg`
  - `ansible/requirements.yml`
  - `ansible/inventory/aws_ec2.yml`
  - `ansible/inventory/dev.ini`
  - `ansible/group_vars/all.yml`, `bastion.yml`, `k8s_masters.yml`, `k8s_workers.yml`
  - `ansible/roles/common/tasks/main.yml`
  - `ansible/roles/containerd/tasks/main.yml`, `handlers/main.yml`
  - `ansible/roles/k8s_base/tasks/main.yml`
  - `ansible/roles/k8s_master/tasks/main.yml`
  - `ansible/roles/k8s_worker/tasks/main.yml`
  - `ansible/roles/bastion/tasks/main.yml`
  - `ansible/playbooks/site.yml`, `bootstrap-cluster.yml`, `setup-bastion.yml`
  - `handoffs/ahmed-nabil/ansible-k8s-setup/HANDOFF_REPORT.md`
  - `handoffs/ahmed-nabil/ansible-k8s-setup/verification-logs.txt`
- **Exact Actions & Changes Made:**
  - Claimed the Ansible K8s & Bastion setup task in `DEVOPS_COLLABORATION.md`.
  - Configured static (`dev.ini` with Bastion ProxyCommand) and dynamic (`aws_ec2.yml` targeting `eu-west-3` and `dev` tags) inventories for Ubuntu 24.04 EC2 nodes.
  - Created 6 idempotent Ansible roles (`common`, `containerd`, `k8s_base`, `k8s_master`, `k8s_worker`, `bastion`) and 3 playbooks (`site.yml`, `bootstrap-cluster.yml`, `setup-bastion.yml`) to provision Kubernetes v1.31 with Flannel CNI and configure Bastion admin tools (`kubectl`, `helm`, `psql`, `awscli`).
- **Verification Commands Executed & Output:**
  - Command: `ansible-playbook -i inventory/dev.ini playbooks/site.yml --syntax-check` | Result: `PASS (exit 0)`
  - Command: `ansible-lint` | Result: `PASS (exit 0)` | Summary: `Passed: 0 failure(s), 0 warning(s) in 22 files processed (production profile)`
- **Status:** `IN_PROGRESS` (Awaiting live EC2 outputs from Terraform `apply` to run against live cluster)
- **Next Step / Handoff Note:** Once Terraform `dev` environment is applied, populate `bastion_public_ip`, `k8s_master_private_ip`, and `k8s_worker_private_ips` in `ansible/inventory/dev.ini` (or run with `-i inventory/aws_ec2.yml`) and execute `ansible-playbook playbooks/site.yml`.

### [2026-11-27 19:05:00 UTC] — Built Complete Ansible K8s Cluster & Bastion Configuration
- **Collaborator / Owner Name:** Ahmed Nabil (`@ahmedsiam1`)
- **AI Agent / Model Used:** Gemini
- **Branch / PR:** `config/ansible-k8s` / Pending PR
- **Files Modified / Created:**
  - `DEVOPS_COLLABORATION.md`
  - `ansible/ansible.cfg`
  - `ansible/requirements.yml`
  - `ansible/inventory/aws_ec2.yml`
  - `ansible/inventory/dev.ini`
  - `ansible/group_vars/all.yml`, `bastion.yml`, `k8s_masters.yml`, `k8s_workers.yml`
  - `ansible/roles/common/tasks/main.yml`
  - `ansible/roles/containerd/tasks/main.yml`, `handlers/main.yml`
  - `ansible/roles/k8s_base/tasks/main.yml`
  - `ansible/roles/k8s_master/tasks/main.yml`
  - `ansible/roles/k8s_worker/tasks/main.yml`
  - `ansible/roles/bastion/tasks/main.yml`
  - `ansible/playbooks/site.yml`, `bootstrap-cluster.yml`, `setup-bastion.yml`
  - `handoffs/ahmed-nabil/ansible-k8s-setup/HANDOFF_REPORT.md`
  - `handoffs/ahmed-nabil/ansible-k8s-setup/verification-logs.txt`
- **Exact Actions & Changes Made:**
  - Claimed the Ansible K8s & Bastion setup task in `DEVOPS_COLLABORATION.md`.
  - Configured static (`dev.ini` with Bastion ProxyCommand) and dynamic (`aws_ec2.yml` targeting `eu-west-3` and `dev` tags) inventories for Ubuntu 24.04 EC2 nodes.
  - Created 6 idempotent Ansible roles (`common`, `containerd`, `k8s_base`, `k8s_master`, `k8s_worker`, `bastion`) and 3 playbooks (`site.yml`, `bootstrap-cluster.yml`, `setup-bastion.yml`) to provision Kubernetes v1.31 with Flannel CNI and configure Bastion admin tools (`kubectl`, `helm`, `psql`, `awscli`).
- **Verification Commands Executed & Output:**
  - Command: `ansible-playbook -i inventory/dev.ini playbooks/site.yml --syntax-check` | Result: `PASS (exit 0)`
  - Command: `ansible-lint` | Result: `PASS (exit 0)` | Summary: `Passed: 0 failure(s), 0 warning(s) in 22 files processed (production profile)`
- **Status:** `IN_PROGRESS` (Awaiting live EC2 outputs from Terraform `apply` to run against live cluster)
- **Next Step / Handoff Note:** Once Terraform `dev` environment is applied, populate `bastion_public_ip`, `k8s_master_private_ip`, and `k8s_worker_private_ips` in `ansible/inventory/dev.ini` (or run with `-i inventory/aws_ec2.yml`) and execute `ansible-playbook playbooks/site.yml`.

### [2026-11-27 19:05:00 UTC] — Built Complete Ansible K8s Cluster & Bastion Configuration
- **Collaborator / Owner Name:** Ahmed Nabil (`@ahmedsiam1`)
- **AI Agent / Model Used:** Gemini
- **Branch / PR:** `config/ansible-k8s` / Pending PR
- **Files Modified / Created:**
  - `DEVOPS_COLLABORATION.md`
  - `ansible/ansible.cfg`
  - `ansible/requirements.yml`
  - `ansible/inventory/aws_ec2.yml`
  - `ansible/inventory/dev.ini`
  - `ansible/group_vars/all.yml`, `bastion.yml`, `k8s_masters.yml`, `k8s_workers.yml`
  - `ansible/roles/common/tasks/main.yml`
  - `ansible/roles/containerd/tasks/main.yml`, `handlers/main.yml`
  - `ansible/roles/k8s_base/tasks/main.yml`
  - `ansible/roles/k8s_master/tasks/main.yml`
  - `ansible/roles/k8s_worker/tasks/main.yml`
  - `ansible/roles/bastion/tasks/main.yml`
  - `ansible/playbooks/site.yml`, `bootstrap-cluster.yml`, `setup-bastion.yml`
  - `handoffs/ahmed-nabil/ansible-k8s-setup/HANDOFF_REPORT.md`
  - `handoffs/ahmed-nabil/ansible-k8s-setup/verification-logs.txt`
- **Exact Actions & Changes Made:**
  - Claimed the Ansible K8s & Bastion setup task in `DEVOPS_COLLABORATION.md`.
  - Configured static (`dev.ini` with Bastion ProxyCommand) and dynamic (`aws_ec2.yml` targeting `eu-west-3` and `dev` tags) inventories for Ubuntu 24.04 EC2 nodes.
  - Created 6 idempotent Ansible roles (`common`, `containerd`, `k8s_base`, `k8s_master`, `k8s_worker`, `bastion`) and 3 playbooks (`site.yml`, `bootstrap-cluster.yml`, `setup-bastion.yml`) to provision Kubernetes v1.31 with Flannel CNI and configure Bastion admin tools (`kubectl`, `helm`, `psql`, `awscli`).
- **Verification Commands Executed & Output:**
  - Command: `ansible-playbook -i inventory/dev.ini playbooks/site.yml --syntax-check` | Result: `PASS (exit 0)`
  - Command: `ansible-lint` | Result: `PASS (exit 0)` | Summary: `Passed: 0 failure(s), 0 warning(s) in 22 files processed (production profile)`
- **Status:** `IN_PROGRESS` (Awaiting live EC2 outputs from Terraform `apply` to run against live cluster)
- **Next Step / Handoff Note:** Once Terraform `dev` environment is applied, populate `bastion_public_ip`, `k8s_master_private_ip`, and `k8s_worker_private_ips` in `ansible/inventory/dev.ini` (or run with `-i inventory/aws_ec2.yml`) and execute `ansible-playbook playbooks/site.yml`.
"""

updated = content.replace(marker, new_entry, 1)
with open("AI_ACTIVITY_AUDIT_LOG.md", "w", encoding="utf-8") as f:
    f.write(updated)
print("Audit log updated successfully.")
EOF
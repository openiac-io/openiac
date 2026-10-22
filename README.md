# OpenIaC — Hybrid Cloud & Container Platform Framework

[![OpenIaC CI Quality Gate](https://github.com/openiac-io/openiac/actions/workflows/ci.yml/badge.svg)](https://github.com/openiac-io/openiac/actions/workflows/ci.yml)

**OpenIaC** is an enterprise-grade, 100% open-source Infrastructure as Code (IaC) framework designed to provision **Container, Cloud-Native Virtualization, and Private/Public Cloud Platforms** with a single command.

Built with a **Zero-Knowledge UX** philosophy and a **3-Layer Composable Stack Architecture**, OpenIaC abstracts away complex kernel tuning, agent-based ISO generation, Layer-3 operator lifecycles, and air-gapped dependency chains behind sensible defaults—allowing anyone to deploy and manage production-ready platforms effortlessly.

---

## 🎯 Supported Tier-1 Platforms

| Layer / Domain | Platform | Engine / Tech Stack | Air-gapped Ready | Entrypoint Command |
| :--- | :--- | :--- | :---: | :--- |
| **Layer-2 Container** | **`k8s`** | Upstream Kubernetes (`kubeadm` + `containerd` + `Calico`) | ✅ | `make k8s` |
| **Layer-2 Container** | **`k3s`** | Lightweight Kubernetes (SUSE Rancher K3s) | ✅ | `make k3s` |
| **Layer-2 Container** | **`openshift`** | Unified **OKD** & **Red Hat OCP** (`Agent-based Installer` 4.12+) | ✅ | `make openshift` |
| **Layer-3 Virtualization** | **`kubevirt`** | Turnkey or Add-on VM Virtualization on K8s / K3s / OpenShift (`KubeVirt` + `CDI`) | ✅ | `make kubevirt` |
| **Layer-2 Private Cloud** | **`openstack`** | Private Cloud IaaS (`Kolla-Ansible` Containerized) | ✅ | `make openstack` |
| **Public Cloud (AWS)** | **`aws`** | Amazon EKS All-in-One Production Platform | — | `make aws-apply` |
| **Public Cloud (GCP)** | **`gcp`** | Google Kubernetes Engine (GKE) Production Platform | — | `make gcp-apply` |
| **Public Cloud (Azure)** | **`azure`** | Azure Kubernetes Service (AKS) Production Platform | — | `make azure-apply` |

---

## 📂 Repository Structure

```text
openiac/
├── .github/workflows/ci.yml # Automated CI Quality Gate (Ansible, Jinja2, Bash, Terraform)
├── Makefile                 # One-command CLI entrypoint for deployment & lifecycle actions
├── ansible/                 # On-Premise & Private Cloud Automation (RHEL / Rocky Linux)
│   ├── inventories/         # Pre-configured sample topologies (k3s, k8s, openshift, openstack)
│   ├── playbooks/           # Standalone, turnkey, and template validation playbooks
│   └── roles/               # Pluggable lifecycle roles (base_os, k3s, k8s, openshift, kubevirt, openstack)
├── terraform/               # Public Cloud Production Blueprints (HCL)
│   ├── aws/                 # Multi-AZ VPC + Amazon EKS + Managed Node Group
│   ├── gcp/                 # Dedicated VPC + Google GKE + Managed Node Pool
│   └── azure/               # VNet + Azure AKS + Managed Identity
├── packager/                # Modular Air-gapped Artifact Bundler (RPMs, Wheels, Images)
└── vagrant/                 # Local multi-node testbeds on VirtualBox (Rocky Linux)
```

---

## 🚀 Quick Start (Copy-Paste Ready)

### 1. On-Premise Base Platform Deployment (Online or Air-gapped)
Edit the target IP addresses in `ansible/inventories/<platform>-sample/hosts.ini` and run a single command:

```bash
# Deploy Lightweight Kubernetes (K3s)
make k3s

# Deploy Standard Upstream Kubernetes (Kubeadm)
make k8s

# Deploy OpenShift / OKD (Defaults to free OKD; set openshift_edition: "ocp" for Red Hat OCP)
make openshift

# Deploy OpenStack Private Cloud (Kolla-Ansible)
make openstack
```

### 2. Cloud-Native VM Virtualization (`kubevirt`) & Composable Add-on Lifecycle
`kubevirt` operates seamlessly as both a **Turnkey All-in-One Platform** on fresh servers and a **Composable Layer-3 Add-on** on top of `k8s`, `k3s`, or `openshift`:

```bash
# Option A: Turnkey All-in-One (Auto-installs Base OS + K8s + KubeVirt if no cluster exists!)
make kubevirt

# Option B: Deploy/Upgrade KubeVirt on an existing OpenShift / OKD cluster
make openshift-kubevirt

# Option C: Automatically install KubeVirt during 'make k8s' or 'make openshift'
# -> Set 'enable_kubevirt_addon: true' in inventories/<platform>-sample/group_vars/all.yml

# Option D: Cleanly Uninstall KubeVirt without affecting the underlying cluster
make kubevirt-uninstall
```

### 3. Air-gapped (Offline) Artifact Packaging
On an internet-connected RHEL / Rocky Linux host, bundle all required binaries, RPMs, and container images into a portable tarball:

```bash
make pack-k3s
make pack-k8s
make pack-openshift
make pack-kubevirt
make pack-openstack
```

### 4. Public Cloud Provisioning (Terraform)
All public cloud modules come with sensible defaults. Authenticate with your cloud CLI and run:

```bash
# Provision Amazon EKS on AWS
make aws-apply

# Provision Google GKE on GCP
make gcp-apply

# Provision Azure AKS on Azure
make azure-apply
```

### 5. Automated Code & Schema Validation
Validate all Ansible playbooks, Jinja2 template renderings, Bash packager scripts, and Terraform HCL schemas with a single command:

```bash
make validate
```

---

## 🛡️ Architecture Principles
* **3-Layer Composable Stack**: Cleanly separates **Layer-1 Underlay OS** (`base_os`), **Layer-2 Core Platforms** (`k8s`, `k3s`, `openshift`, `openstack`), and **Layer-3 Add-on Operators** (`kubevirt`) with full Day-2 lifecycle control (`present` / `absent` / version upgrades).
* **Pluggable Lifecycle & Engine Dispatch Pattern**: Every role separates its router (`tasks/main.yml`) from its lifecycle/engine modules (`tasks/install_<method>.yml`, `tasks/uninstall_<method>.yml`), allowing new installation methods and Day-2 actions to be plugged in seamlessly.
* **Self-Healing & Built-in Helpers**: OpenShift static NMState Agent ISOs, OpenStack Cinder LVM volume groups, Neutron dummy interfaces, and KubeVirt emulation fallbacks are configured automatically—no manual prerequisite setup required.
* **Zero External Ansible Dependencies**: Built strictly with `ansible.builtin` FQCN modules so playbooks run out-of-the-box on minimal `ansible-core` installations.

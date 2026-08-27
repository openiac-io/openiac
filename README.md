# OpenIaC Core Monorepo

Welcome to the **OpenIaC Core Monorepo**. This repository contains the community-driven, 100% open-source Infrastructure as Code (IaC) toolset for deploying enterprise-grade baremetal and air-gapped environments.

## 🚀 Architecture Overview

This monorepo serves as a "Swiss Army Knife" for infrastructure provisioning. By adjusting simple feature flags, you can deploy everything from base OS configurations to Kubernetes (RKE2/K3s), OpenStack, and private registries.

### Directory Structure

- **`ansible/`**: The heart of the provisioning logic.
  - `inventories/`: Define your target nodes (baremetal, VMs).
  - `playbooks/`: Entry points for deployment (e.g., `site.yml`).
  - `roles/`: Highly modular Ansible roles (e.g., `base_os`, `k8s`, `openstack`).
- **`packager/`**: Scripts to collect and bundle offline artifacts (Docker images, RPMs/DEBs, binaries) into a single tarball for air-gapped deployment.

## 🛡️ Monetization & Enterprise Support

While all code in this repository is completely **Open Source and Free to use**, compiling the offline artifacts (`offline-images.tar.gz`) requires significant time, internet bandwidth, and stable build environments. 

For enterprise environments that need guaranteed stability and zero hassle, we offer the **OpenIaC Enterprise Subscription**, which provides:
1. **Pre-built & Verified Artifacts**: Instantly download the 50GB+ offline tarballs.
2. **Technical Support SLA**: Expert troubleshooting for your air-gapped baremetal setups.

---
*Built for infrastructure engineers, by infrastructure engineers.*

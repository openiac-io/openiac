# ==============================================================================
# OpenIaC One-Command Execution Entrypoint (Makefile)
# ==============================================================================
# Provides a zero-knowledge, user-friendly CLI interface for provisioning
# on-premise and public cloud platforms with a single command.

.PHONY: help validate k3s k8s openshift kubevirt openshift-kubevirt kubevirt-uninstall openstack \
        pack-k3s pack-k8s pack-openshift pack-kubevirt pack-openstack \
        aws-init aws-plan aws-apply gcp-init gcp-plan gcp-apply azure-init azure-plan azure-apply

help:
	@echo "=============================================================================="
	@echo " OpenIaC - Enterprise Hybrid Cloud & Container Platform Framework"
	@echo "=============================================================================="
	@echo ""
	@echo " [1] On-Premise Platform & Add-on Deployment (Ansible):"
	@echo "   make k3s                Deploy Lightweight Kubernetes (K3s)"
	@echo "   make k8s                Deploy Standard Upstream Kubernetes (Kubeadm)"
	@echo "   make openshift          Deploy OpenShift / OKD Container Platform"
	@echo "   make kubevirt           Deploy/Upgrade KubeVirt (Auto-installs K8s if empty)"
	@echo "   make openshift-kubevirt Deploy/Upgrade KubeVirt on an OpenShift Cluster"
	@echo "   make kubevirt-uninstall Cleanly Uninstall KubeVirt from the Cluster"
	@echo "   make openstack          Deploy OpenStack Private Cloud (Kolla-Ansible)"
	@echo ""
	@echo " [2] Air-gapped Offline Artifact Packager:"
	@echo "   make pack-k3s           Bundle offline artifacts for K3s"
	@echo "   make pack-k8s           Bundle offline artifacts for Standard K8s"
	@echo "   make pack-openshift     Bundle offline artifacts for OpenShift / OKD"
	@echo "   make pack-kubevirt      Bundle offline artifacts for KubeVirt"
	@echo "   make pack-openstack     Bundle offline artifacts for OpenStack"
	@echo ""
	@echo " [3] Public Cloud Platform Provisioning (Terraform):"
	@echo "   make aws-apply          Provision AWS EKS Production Platform"
	@echo "   make gcp-apply          Provision GCP GKE Production Platform"
	@echo "   make azure-apply        Provision Azure AKS Production Platform"
	@echo ""
	@echo " [4] Automated Quality & Schema Verification:"
	@echo "   make validate           Run Ansible, Jinja2, Bash, and Terraform validation"
	@echo "=============================================================================="

# ------------------------------------------------------------------------------
# 1. On-Premise Platform & Lifecycle Targets
# ------------------------------------------------------------------------------
k3s:
	cd ansible && ansible-playbook -i inventories/k3s-sample/hosts.ini playbooks/k3s.yml

k8s:
	cd ansible && ansible-playbook -i inventories/k8s-sample/hosts.ini playbooks/k8s.yml

openshift:
	cd ansible && ansible-playbook -i inventories/openshift-sample/hosts.ini playbooks/openshift.yml

kubevirt:
	cd ansible && ansible-playbook -i inventories/k8s-sample/hosts.ini playbooks/kubevirt.yml

openshift-kubevirt:
	cd ansible && ansible-playbook -i inventories/openshift-sample/hosts.ini playbooks/kubevirt.yml

kubevirt-uninstall:
	cd ansible && ansible-playbook -i inventories/k8s-sample/hosts.ini playbooks/kubevirt.yml -e kubevirt_state=absent

openstack:
	cd ansible && ansible-playbook -i inventories/openstack-sample/hosts.ini playbooks/openstack.yml

# ------------------------------------------------------------------------------
# 2. Air-gapped Offline Packager Targets
# ------------------------------------------------------------------------------
pack-k3s:
	cd packager && bash build_offline_tarball.sh --target k3s

pack-k8s:
	cd packager && bash build_offline_tarball.sh --target k8s

pack-openshift:
	cd packager && bash build_offline_tarball.sh --target openshift

pack-kubevirt:
	cd packager && bash build_offline_tarball.sh --target kubevirt

pack-openstack:
	cd packager && bash build_offline_tarball.sh --target openstack

# ------------------------------------------------------------------------------
# 3. Public Cloud Terraform Targets
# ------------------------------------------------------------------------------
aws-init:
	terraform -chdir=terraform/aws init

aws-plan: aws-init
	terraform -chdir=terraform/aws plan

aws-apply: aws-init
	terraform -chdir=terraform/aws apply

gcp-init:
	terraform -chdir=terraform/gcp init

gcp-plan: gcp-init
	terraform -chdir=terraform/gcp plan

gcp-apply: gcp-init
	terraform -chdir=terraform/gcp apply

azure-init:
	terraform -chdir=terraform/azure init

azure-plan: azure-init
	terraform -chdir=terraform/azure plan

azure-apply: azure-init
	terraform -chdir=terraform/azure apply

# ------------------------------------------------------------------------------
# 4. Automated Code & Template Verification Target
# ------------------------------------------------------------------------------
validate:
	@echo "===> [1/3] Validating Ansible Playbooks & Jinja2 Templates..."
	cd ansible && ansible-playbook -i inventories/k3s-sample/hosts.ini playbooks/k3s.yml --syntax-check
	cd ansible && ansible-playbook -i inventories/k8s-sample/hosts.ini playbooks/k8s.yml --syntax-check
	cd ansible && ansible-playbook -i inventories/openshift-sample/hosts.ini playbooks/openshift.yml --syntax-check
	cd ansible && ansible-playbook -i inventories/k8s-sample/hosts.ini playbooks/kubevirt.yml --syntax-check
	cd ansible && ansible-playbook -i inventories/openshift-sample/hosts.ini playbooks/kubevirt.yml --syntax-check
	cd ansible && ansible-playbook -i inventories/openstack-sample/hosts.ini playbooks/openstack.yml --syntax-check
	cd ansible && ansible-playbook -i inventories/openshift-sample/hosts.ini playbooks/validate_templates.yml
	@echo "===> [2/3] Validating Packager Bash Scripts..."
	bash -n packager/build_offline_tarball.sh
	for s in packager/scripts/*.sh; do bash -n "$$s"; done
	@echo "===> [3/3] Validating Public Cloud Terraform Modules..."
	terraform fmt -check -recursive terraform/
	for d in aws gcp azure; do terraform -chdir=terraform/$$d init -backend=false && terraform -chdir=terraform/$$d validate; done
	@echo "===> [SUCCESS] All OpenIaC validation checks passed!"

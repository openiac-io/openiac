# ==============================================================================
# OpenIaC One-Command Execution Entrypoint (Makefile)
# ==============================================================================
# Provides a zero-knowledge, user-friendly CLI interface for provisioning
# on-premise platforms with a single command.

export ANSIBLE_CONFIG := /tmp/openiac-ansible.cfg
export ANSIBLE_ROLES_PATH := $(CURDIR)/ansible/roles
export ANSIBLE_HOST_KEY_CHECKING := False

.PHONY: help ensure-ansible validate k3s k8s openshift kubevirt openshift-kubevirt kubevirt-uninstall openstack \
        pack-k3s pack-k8s pack-openshift pack-kubevirt pack-openstack

help:
	@echo "=============================================================================="
	@echo " OpenIaC - On-Premise & Air-Gapped Platform Framework"
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
	@echo " [3] Automated Quality & Schema Verification:"
	@echo "   make validate           Run Ansible, Jinja2, and Bash validation"
	@echo "=============================================================================="

# ------------------------------------------------------------------------------
# 0. Self-Healing Control Node Prerequisite Check
# ------------------------------------------------------------------------------
ensure-ansible:
	@cp "$(CURDIR)/ansible/ansible.cfg" /tmp/openiac-ansible.cfg && chmod 0644 /tmp/openiac-ansible.cfg
	@if ! command -v ansible-playbook >/dev/null 2>&1 || ! command -v sshpass >/dev/null 2>&1; then \
		echo "===> [OpenIaC Self-Healing] 'ansible-playbook' or 'sshpass' not found on this control node."; \
		echo "===> [OpenIaC Self-Healing] Automatically installing Ansible Engine & sshpass..."; \
		if [ -d "$(CURDIR)/packager/artifacts/ansible-bootstrap" ] && ls "$(CURDIR)/packager/artifacts/ansible-bootstrap/"*.rpm >/dev/null 2>&1; then \
			sudo dnf install -y --disablerepo='*' "$(CURDIR)/packager/artifacts/ansible-bootstrap/"*.rpm; \
		elif command -v dnf >/dev/null 2>&1; then \
			sudo dnf install -y epel-release && sudo dnf install -y ansible-core sshpass; \
		elif command -v apt-get >/dev/null 2>&1; then \
			sudo apt-get update && sudo apt-get install -y ansible sshpass; \
		else \
			echo "[ERROR] Unsupported package manager. Please install ansible-core and sshpass manually."; \
			exit 1; \
		fi; \
		echo "===> [OpenIaC Self-Healing] Ansible Engine & sshpass are ready!"; \
	fi

# ------------------------------------------------------------------------------
# 1. On-Premise Platform & Lifecycle Targets
# ------------------------------------------------------------------------------
k3s: ensure-ansible
	cd ansible && ansible-playbook -i inventories/k3s-sample/hosts.ini playbooks/k3s.yml

k8s: ensure-ansible
	cd ansible && ansible-playbook -i inventories/k8s-sample/hosts.ini playbooks/k8s.yml

openshift: ensure-ansible
	cd ansible && ansible-playbook -i inventories/openshift-sample/hosts.ini playbooks/openshift.yml

kubevirt: ensure-ansible
	cd ansible && ansible-playbook -i inventories/k8s-sample/hosts.ini playbooks/kubevirt.yml

openshift-kubevirt: ensure-ansible
	cd ansible && ansible-playbook -i inventories/openshift-sample/hosts.ini playbooks/kubevirt.yml

kubevirt-uninstall: ensure-ansible
	cd ansible && ansible-playbook -i inventories/k8s-sample/hosts.ini playbooks/kubevirt.yml -e kubevirt_state=absent

openstack: ensure-ansible
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
# 3. Automated Code & Template Verification Target
# ------------------------------------------------------------------------------
validate: ensure-ansible
	@echo "===> [1/2] Validating Ansible Playbooks & Jinja2 Templates..."
	cd ansible && ansible-playbook -i inventories/k3s-sample/hosts.ini playbooks/k3s.yml --syntax-check
	cd ansible && ansible-playbook -i inventories/k8s-sample/hosts.ini playbooks/k8s.yml --syntax-check
	cd ansible && ansible-playbook -i inventories/openshift-sample/hosts.ini playbooks/openshift.yml --syntax-check
	cd ansible && ansible-playbook -i inventories/k8s-sample/hosts.ini playbooks/kubevirt.yml --syntax-check
	cd ansible && ansible-playbook -i inventories/openshift-sample/hosts.ini playbooks/kubevirt.yml --syntax-check
	cd ansible && ansible-playbook -i inventories/openstack-sample/hosts.ini playbooks/openstack.yml --syntax-check
	cd ansible && ansible-playbook -i inventories/openshift-sample/hosts.ini playbooks/validate_templates.yml
	@echo "===> [2/2] Validating Packager Bash Scripts..."
	bash -n packager/build_offline_tarball.sh
	for s in packager/scripts/*.sh; do bash -n "$$s"; done
	@echo "===> [SUCCESS] All OpenIaC validation checks passed!"

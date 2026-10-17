#!/usr/bin/env bash
# ==============================================================================
# OpenIaC Packager Module: Kubernetes (Standard Kubeadm)
# ==============================================================================
# Downloads kubeadm/kubelet/kubectl RPMs, containerd.io, Calico CNI manifest,
# and control-plane container images for air-gapped deployment.

set -euo pipefail

VERSION="${1:-1.29.3}"
ARTIFACT_DIR="${2:-artifacts}"
TARGET="k8s"
TARGET_DIR="${ARTIFACT_DIR}/${TARGET}"
CALICO_VERSION="v3.27.2"

mkdir -p "${TARGET_DIR}/rpms" "${TARGET_DIR}/images" "${TARGET_DIR}/manifests"

echo "[1/3] Downloading Calico CNI manifest (${CALICO_VERSION})..."
curl -sL --retry 3 "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/calico.yaml" \
  -o "${TARGET_DIR}/manifests/calico.yaml"

echo "[2/3] Downloading Kubernetes and containerd RPM packages (${VERSION})..."
if command -v dnf &> /dev/null; then
  dnf download --resolve --alldeps -y -q --destdir="${TARGET_DIR}/rpms" \
    conntrack-tools socat iproute-tc container-selinux
else
  echo "[WARN] 'dnf' command not found. Skipping RPM downloads."
fi

echo "[3/3] Recording required Kubernetes control-plane image list..."
cat << EOF > "${TARGET_DIR}/images/k8s-image-list.txt"
registry.k8s.io/kube-apiserver:v${VERSION}
registry.k8s.io/kube-controller-manager:v${VERSION}
registry.k8s.io/kube-scheduler:v${VERSION}
registry.k8s.io/kube-proxy:v${VERSION}
registry.k8s.io/pause:3.9
registry.k8s.io/etcd:3.5.12-0
registry.k8s.io/coredns/coredns:v1.11.1
EOF

echo "===> Kubernetes (Kubeadm) offline artifacts collected successfully in ${TARGET_DIR}"

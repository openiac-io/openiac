#!/usr/bin/env bash
# ==============================================================================
# OpenIaC Packager Module: K3s (Lightweight Kubernetes)
# ==============================================================================
# Downloads K3s binary, air-gap container image tarball, install script, and
# required Enterprise Linux RPM dependencies.

set -euo pipefail

VERSION="${1:-v1.28.4+k3s2}"
ARTIFACT_DIR="${2:-artifacts}"
TARGET="k3s"
TARGET_DIR="${ARTIFACT_DIR}/${TARGET}"

mkdir -p "${TARGET_DIR}/rpms"

echo "[1/3] Downloading K3s binary and install script (${VERSION})..."
curl -sL --retry 3 "https://github.com/k3s-io/k3s/releases/download/${VERSION}/k3s" -o "${TARGET_DIR}/k3s-${VERSION}"
chmod +x "${TARGET_DIR}/k3s-${VERSION}"
curl -sL --retry 3 "https://get.k3s.io" -o "${TARGET_DIR}/install.sh"
chmod +x "${TARGET_DIR}/install.sh"

echo "[2/3] Downloading K3s air-gap container images..."
curl -sL --retry 3 "https://github.com/k3s-io/k3s/releases/download/${VERSION}/k3s-airgap-images-amd64.tar" \
  -o "${TARGET_DIR}/k3s-airgap-images-${VERSION}-amd64.tar"

echo "[3/3] Downloading offline RPM dependencies for Enterprise Linux..."
if command -v dnf &> /dev/null; then
  dnf download --resolve --alldeps -y -q --destdir="${TARGET_DIR}/rpms" \
    container-selinux iptables iptables-libs libnetfilter_conntrack libnfnetlink iptables-nft
else
  echo "[WARN] 'dnf' command not found. Skipping RPM downloads."
fi

echo "===> K3s offline artifacts collected successfully in ${TARGET_DIR}"

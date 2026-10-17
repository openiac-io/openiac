#!/usr/bin/env bash
# ==============================================================================
# OpenIaC Packager Module: OpenShift (OKD / Red Hat OCP)
# ==============================================================================
# Downloads openshift-install, oc client binaries, and bastion RPM dependencies
# for air-gapped OpenShift / OKD deployments.

set -euo pipefail

VERSION="${1:-4.15.0-0.okd-2024-03-10-010116}"
ARTIFACT_DIR="${2:-artifacts}"
TARGET="openshift"
TARGET_DIR="${ARTIFACT_DIR}/${TARGET}"

mkdir -p "${TARGET_DIR}/rpms"

echo "[1/3] Downloading OpenShift / OKD installer binary (${VERSION})..."
curl -sL --retry 3 "https://github.com/okd-project/okd/releases/download/${VERSION}/openshift-install-linux-${VERSION}.tar.gz" \
  -o "${TARGET_DIR}/openshift-install-linux.tar.gz"

echo "[2/3] Downloading OpenShift (oc) & kubectl client bundle (${VERSION})..."
curl -sL --retry 3 "https://github.com/okd-project/okd/releases/download/${VERSION}/openshift-client-linux-${VERSION}.tar.gz" \
  -o "${TARGET_DIR}/openshift-client-linux.tar.gz"

echo "[3/3] Downloading bastion RPM dependencies (haproxy, podman, jq)..."
if command -v dnf &> /dev/null; then
  dnf download --resolve --alldeps -y -q --destdir="${TARGET_DIR}/rpms" \
    haproxy podman jq tar
else
  echo "[WARN] 'dnf' command not found. Skipping RPM downloads."
fi

echo "===> OpenShift / OKD offline artifacts collected successfully in ${TARGET_DIR}"

#!/usr/bin/env bash
# ==============================================================================
# OpenIaC Packager Module: KubeVirt (Cloud-Native Virtualization)
# ==============================================================================
# Downloads KubeVirt Operator, CDI manifests, and virtctl CLI binary for
# air-gapped VM virtualization on Kubernetes / OpenShift.

set -euo pipefail

VERSION="${1:-v1.2.0}"
ARTIFACT_DIR="${2:-artifacts}"
TARGET="kubevirt"
TARGET_DIR="${ARTIFACT_DIR}/${TARGET}"
CDI_VERSION="v1.59.0"

mkdir -p "${TARGET_DIR}"

echo "[1/3] Downloading KubeVirt Operator & CR manifests (${VERSION})..."
curl -sL --retry 3 "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml" \
  -o "${TARGET_DIR}/kubevirt-operator.yaml"
curl -sL --retry 3 "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml" \
  -o "${TARGET_DIR}/kubevirt-cr.yaml"

echo "[2/3] Downloading Containerized Data Importer (CDI) manifests (${CDI_VERSION})..."
curl -sL --retry 3 "https://github.com/kubevirt/containerized-data-importer/releases/download/${CDI_VERSION}/cdi-operator.yaml" \
  -o "${TARGET_DIR}/cdi-operator.yaml"
curl -sL --retry 3 "https://github.com/kubevirt/containerized-data-importer/releases/download/${CDI_VERSION}/cdi-cr.yaml" \
  -o "${TARGET_DIR}/cdi-cr.yaml"

echo "[3/3] Downloading virtctl CLI binary (${VERSION})..."
curl -sL --retry 3 "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-linux-amd64" \
  -o "${TARGET_DIR}/virtctl-${VERSION}-linux-amd64"
chmod +x "${TARGET_DIR}/virtctl-${VERSION}-linux-amd64"

echo "===> KubeVirt offline artifacts collected successfully in ${TARGET_DIR}"

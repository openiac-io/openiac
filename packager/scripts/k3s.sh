#!/bin/bash
# ==============================================================================
# OpenIaC Packager: K3s Offline Artifacts Downloader (RHEL/Rocky 9)
# ==============================================================================
set -e

VERSION="${1}"
ARTIFACT_DIR="${2}"
TARGET="k3s"

# Default to latest stable if no version specified
if [ -z "$VERSION" ]; then
    VERSION="v1.28.4+k3s2"
fi

TARGET_DIR="${ARTIFACT_DIR}/${TARGET}"
mkdir -p "${TARGET_DIR}"

echo "[1/3] Downloading K3s binary (${VERSION})..."
curl -sL --retry 3 "https://github.com/k3s-io/k3s/releases/download/${VERSION}/k3s" -o "${TARGET_DIR}/k3s"
chmod +x "${TARGET_DIR}/k3s"

echo "[2/3] Downloading K3s air-gap container images..."
curl -sL --retry 3 "https://github.com/k3s-io/k3s/releases/download/${VERSION}/k3s-airgap-images-amd64.tar" -o "${TARGET_DIR}/k3s-airgap-images-amd64.tar"

echo "[3/3] Downloading offline dependencies (RPM packages) for Rocky Linux 9..."
mkdir -p "${TARGET_DIR}/rpms"
# Note: For production use, you should run this command on a fresh Rocky Linux 9 machine 
# to ensure it resolves and downloads all necessary dependencies.
if command -v dnf &> /dev/null; then
    dnf download --resolve --alldeps -y -q --destdir="${TARGET_DIR}/rpms" container-selinux iptables iptables-libs libnetfilter_conntrack libnfnetlink iptables-nft
else
    echo "??Warning: 'dnf' command not found. Skipping RPM downloads. (Run this on Rocky Linux to collect RPMs)"
fi

echo "? K3s RHEL/Rocky artifacts collected successfully in ${TARGET_DIR}"

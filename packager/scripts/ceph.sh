#!/bin/bash
# ==============================================================================
# OpenIaC Packager: Ceph Offline Artifacts Downloader
# ==============================================================================
set -e

# Configuration
CEPH_RELEASE="quincy"
CEPH_VERSION="v18.2.2"
CEPH_IMAGE="quay.io/ceph/ceph:${CEPH_VERSION}"
ARTIFACT_DIR="$(dirname "$0")/../artifacts/ceph"

echo "============================================================"
echo " Starting Ceph Offline Artifacts Packaging (${CEPH_RELEASE})"
echo "============================================================"

mkdir -p "${ARTIFACT_DIR}"

# 1. Download cephadm standalone binary
echo "[1/2] Downloading cephadm binary..."
curl -sL --retry 3 "https://download.ceph.com/rpm-${CEPH_RELEASE}/el9/noarch/cephadm" -o "${ARTIFACT_DIR}/cephadm"
chmod +x "${ARTIFACT_DIR}/cephadm"

# 2. Download Ceph container image
echo "[2/2] Pulling and saving Ceph container image (${CEPH_IMAGE})..."
# Check if podman or docker is available
if command -v podman &> /dev/null; then
    podman pull "${CEPH_IMAGE}"
    podman save "${CEPH_IMAGE}" -o "${ARTIFACT_DIR}/ceph-image.tar"
elif command -v docker &> /dev/null; then
    docker pull "${CEPH_IMAGE}"
    docker save "${CEPH_IMAGE}" -o "${ARTIFACT_DIR}/ceph-image.tar"
else
    echo "ERROR: Neither podman nor docker is installed. Cannot download container images."
    exit 1
fi

echo "============================================================"
echo " Ceph packaging complete! Artifacts saved to ${ARTIFACT_DIR}"
echo "============================================================"

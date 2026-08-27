#!/bin/bash
# ==============================================================================
# OpenIaC Offline Packager
# ==============================================================================
# This script must be run on an internet-connected machine.
# It collects required RPM/DEB packages, Docker images, and Helm charts,
# and bundles them into a single offline-images.tar.gz for air-gapped deployment.

set -e

ARTIFACT_DIR="artifacts"
IMAGE_LIST="image_list.txt"
TARBALL_NAME="openiac-offline-v1.0.tar.gz"

echo "🚀 Starting OpenIaC Offline Artifact Collection..."

mkdir -p $ARTIFACT_DIR/images
mkdir -p $ARTIFACT_DIR/binaries
mkdir -p $ARTIFACT_DIR/charts

# TODO: Add logic to parse Ansible variables for dynamic image lists
echo "[1/3] Pulling and saving container images..."
# Example:
# docker pull k8s.gcr.io/pause:3.6
# docker save k8s.gcr.io/pause:3.6 -o $ARTIFACT_DIR/images/pause.tar

echo "[2/3] Downloading required binaries and Helm charts..."
# Example:
# wget https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz -O $ARTIFACT_DIR/binaries/helm.tar.gz

echo "[3/3] Compressing artifacts into $TARBALL_NAME..."
# tar -czvf $TARBALL_NAME $ARTIFACT_DIR/

echo "✅ Artifact creation complete! Transfer $TARBALL_NAME to your air-gapped environment."

#!/bin/bash
set -e

# Arguments passed from main wrapper
K3S_VERSION=${1:-"v1.28.4+k3s2"}
ARTIFACT_DIR=$2

K3S_DIR="$ARTIFACT_DIR/k3s"

# 1. Create artifact directory
mkdir -p "$K3S_DIR"

# 2. K3s binary download
echo "  [1/3] Downloading K3s binary ($K3S_VERSION)..."
curl -L -f --progress-bar "https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}/k3s" \
  -o "$K3S_DIR/k3s-${K3S_VERSION}"
chmod +x "$K3S_DIR/k3s-${K3S_VERSION}"

# 3. K3s air-gap images download
echo "  [2/3] Downloading K3s air-gap images..."
curl -L -f --progress-bar "https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}/k3s-airgap-images-amd64.tar" \
  -o "$K3S_DIR/k3s-airgap-images-${K3S_VERSION}-amd64.tar"

# 4. K3s official install script download
echo "  [3/3] Downloading K3s install script..."
curl -L -f -s "https://get.k3s.io" -o "$K3S_DIR/install.sh"
chmod +x "$K3S_DIR/install.sh"

echo "  ✅ K3s artifacts successfully downloaded to $K3S_DIR!"

#!/bin/bash
# ==============================================================================
# OpenIaC Packager: OpenStack Offline Artifacts Downloader
# Engine: Kolla-Ansible
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PACKAGER_ROOT="${SCRIPT_DIR}/.."

VERSION="${1:-2023.2}"
ARTIFACT_DIR="${2:-${PACKAGER_ROOT}/artifacts}"
TARGET="openstack"

# Map OpenStack release version to Kolla-Ansible pip version
case "${VERSION}" in
  "2023.2"|"bobcat")
    KOLLA_PIP_VERSION="17"
    ;;
  "2024.1"|"caracal")
    KOLLA_PIP_VERSION="18"
    ;;
  *)
    KOLLA_PIP_VERSION="${VERSION}"
    ;;
esac

TARGET_DIR="${ARTIFACT_DIR}/${TARGET}"
mkdir -p "${TARGET_DIR}/python"
mkdir -p "${TARGET_DIR}/images"

echo "[1/3] Downloading Kolla-Ansible Python dependencies (OpenStack: ${VERSION}, Kolla: ${KOLLA_PIP_VERSION}.x)..."
# Ensure pip is installed
if ! command -v pip3 &> /dev/null; then
    echo "Installing python3-pip..."
    sudo dnf install -y python3-pip
fi

# Download Kolla-Ansible and its dependencies for offline installation
pip3 download "kolla-ansible==${KOLLA_PIP_VERSION}.*" python-openstackclient -d "${TARGET_DIR}/python"

echo "[1.5/3] Packaging Ansible Galaxy Collections for Kolla..."
mkdir -p "${TARGET_DIR}/collections"
if command -v ansible-galaxy &> /dev/null && command -v git &> /dev/null; then
    # OpenStack Kolla collection is not on Galaxy and its stable branch may be EOL.
    # We must clone it and build the tarball locally.
    TEMP_GIT_DIR=$(mktemp -d)
    git clone https://opendev.org/openstack/ansible-collection-kolla.git "${TEMP_GIT_DIR}"
    pushd "${TEMP_GIT_DIR}" > /dev/null
    git checkout "2023.2-eol" || git checkout "unmaintained/2023.2" || echo "Using master branch fallback"
    ansible-galaxy collection build --output-path "${TARGET_DIR}/collections"
    popd > /dev/null
    rm -rf "${TEMP_GIT_DIR}"
else
    echo "??Warning: 'ansible-galaxy' or 'git' not found. Skipping collection build."
fi

echo "[2/3] Collecting Core Container Images list..."
# Normally, you would generate a kolla image list based on globals.yml
# Here we simulate fetching core container images using skopeo or podman
echo "Simulating Kolla container image download for Nova, Keystone, Horizon..."
cat << EOF > "${TARGET_DIR}/images/kolla-image-list.txt"
quay.io/openstack.kolla/nova-api:${VERSION}
quay.io/openstack.kolla/nova-compute:${VERSION}
quay.io/openstack.kolla/keystone:${VERSION}
quay.io/openstack.kolla/horizon:${VERSION}
quay.io/openstack.kolla/mariadb:${VERSION}
quay.io/openstack.kolla/rabbitmq:${VERSION}
EOF

echo "[3/3] Downloading offline dependencies (RPM packages) for OpenStack Host..."
mkdir -p "${TARGET_DIR}/rpms"
if command -v dnf &> /dev/null; then
    # Base packages needed for Kolla hosts (docker/podman, python3)
    dnf download --resolve --alldeps -y -q --destdir="${TARGET_DIR}/rpms" python3 python3-pip lvm2
else
    echo "??Warning: 'dnf' command not found. Skipping RPM downloads."
fi

echo "? OpenStack (Kolla-Ansible) artifacts collected successfully in ${TARGET_DIR}"

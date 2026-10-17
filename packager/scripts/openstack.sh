#!/usr/bin/env bash
# ==============================================================================
# OpenIaC Packager Module: OpenStack (Kolla-Ansible)
# ==============================================================================
# Downloads Kolla-Ansible Python wheels, Galaxy collections, container image
# manifests, and host RPM dependencies for air-gapped OpenStack deployments.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PACKAGER_ROOT="${SCRIPT_DIR}/.."

VERSION="${1:-2023.2}"
ARTIFACT_DIR="${2:-${PACKAGER_ROOT}/artifacts}"
TARGET="openstack"
TARGET_DIR="${ARTIFACT_DIR}/${TARGET}"

# Map OpenStack release version to Kolla-Ansible major pip version
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

mkdir -p "${TARGET_DIR}/python" "${TARGET_DIR}/images" "${TARGET_DIR}/collections" "${TARGET_DIR}/rpms"

echo "[1/3] Downloading Kolla-Ansible Python wheels (OpenStack: ${VERSION}, Kolla: ${KOLLA_PIP_VERSION}.x)..."
if ! command -v pip3 &> /dev/null; then
  sudo dnf install -y python3-pip
fi
pip3 download "kolla-ansible==${KOLLA_PIP_VERSION}.*" python-openstackclient -d "${TARGET_DIR}/python"

echo "[2/3] Packaging Ansible Galaxy Collections for Kolla..."
if command -v ansible-galaxy &> /dev/null && command -v git &> /dev/null; then
  TEMP_GIT_DIR=$(mktemp -d)
  git clone https://opendev.org/openstack/ansible-collection-kolla.git "${TEMP_GIT_DIR}"
  pushd "${TEMP_GIT_DIR}" > /dev/null
  git checkout "${VERSION}-eol" || git checkout "unmaintained/${VERSION}" || echo "[INFO] Using default branch fallback"
  ansible-galaxy collection build --output-path "${TARGET_DIR}/collections"
  popd > /dev/null
  rm -rf "${TEMP_GIT_DIR}"
else
  echo "[WARN] 'ansible-galaxy' or 'git' not found. Skipping collection build."
fi

echo "[3/3] Downloading offline RPM dependencies for OpenStack hosts..."
cat << EOF > "${TARGET_DIR}/images/kolla-image-list.txt"
quay.io/openstack.kolla/nova-api:${VERSION}
quay.io/openstack.kolla/nova-compute:${VERSION}
quay.io/openstack.kolla/keystone:${VERSION}
quay.io/openstack.kolla/horizon:${VERSION}
quay.io/openstack.kolla/mariadb:${VERSION}
quay.io/openstack.kolla/rabbitmq:${VERSION}
EOF

if command -v dnf &> /dev/null; then
  dnf download --resolve --alldeps -y -q --destdir="${TARGET_DIR}/rpms" \
    python3 python3-pip lvm2 sshpass podman
else
  echo "[WARN] 'dnf' command not found. Skipping RPM downloads."
fi

echo "===> OpenStack (Kolla-Ansible) offline artifacts collected successfully in ${TARGET_DIR}"

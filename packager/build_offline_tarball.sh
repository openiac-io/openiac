#!/usr/bin/env bash
# ==============================================================================
# OpenIaC Modular Offline Packager
# ==============================================================================
# Collects and bundles offline artifacts (binaries, container images, RPMs, wheels)
# for true air-gapped enterprise deployments on RHEL / Rocky Linux.
# Usage: ./build_offline_tarball.sh --target <platform> [--version <version>]

set -euo pipefail

# Default configurations
TARGET=""
VERSION=""
ARTIFACT_DIR="artifacts"

# Argument parsing
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"
      shift
      ;;
    --version)
      VERSION="$2"
      shift
      ;;
    *)
      echo "[ERROR] Unknown parameter passed: $1"
      exit 1
      ;;
  esac
  shift
done

# Validate target
if [[ -z "${TARGET}" ]]; then
  echo "=============================================================================="
  echo "[ERROR] Target platform is required!"
  echo "Usage:   $0 --target <k3s|k8s|openshift|kubevirt|openstack> [--version <ver>]"
  echo "Example: $0 --target k3s --version v1.28.4+k3s2"
  echo "=============================================================================="
  exit 1
fi

SCRIPT_PATH="scripts/${TARGET}.sh"

if [[ ! -f "${SCRIPT_PATH}" ]]; then
  echo "[ERROR] Packager module for '${TARGET}' not found at ${SCRIPT_PATH}"
  exit 1
fi

# ==============================================================================
# [Pre-flight] Enterprise Linux OS Verification
# ==============================================================================
if [[ ! -f "/etc/os-release" ]]; then
  echo "[ERROR] /etc/os-release not found. This script must be run on a Linux host."
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release
if [[ "${ID_LIKE:-}" != *"rhel"* ]] && [[ "${ID_LIKE:-}" != *"centos"* ]] && [[ "${ID_LIKE:-}" != *"fedora"* ]]; then
  echo "[ERROR] Incompatible OS detected (${ID:-unknown})."
  echo "OpenIaC Packager collects RPMs for Enterprise Linux (RHEL / Rocky Linux)."
  exit 1
fi

OS_MAJOR_VERSION=$(echo "${VERSION_ID}" | cut -d'.' -f1)
echo "=============================================================================="
echo "[INFO] Detected Host OS : ${NAME} ${VERSION_ID} (EL${OS_MAJOR_VERSION})"
echo "[INFO] Target Platform  : ${TARGET}"
echo "=============================================================================="

# 1. Execute the platform-specific module script
bash "${SCRIPT_PATH}" "${VERSION}" "${ARTIFACT_DIR}"

# 2. Compress the collected artifacts into a portable tarball
TARBALL_NAME="openiac-${TARGET}-offline-el${OS_MAJOR_VERSION}.tar.gz"
if [[ -n "${VERSION}" ]]; then
  TARBALL_NAME="openiac-${TARGET}-offline-${VERSION//+/-}-el${OS_MAJOR_VERSION}.tar.gz"
fi

echo "===> Compressing offline bundle into ${TARBALL_NAME}..."
tar -czf "${TARBALL_NAME}" "${ARTIFACT_DIR}/${TARGET}"

echo "=============================================================================="
echo "[SUCCESS] Offline artifact bundle created: $(pwd)/${TARBALL_NAME}"
echo "=============================================================================="

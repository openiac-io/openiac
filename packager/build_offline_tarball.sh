#!/bin/bash
# ==============================================================================
# OpenIaC Modular Offline Packager
# ==============================================================================
# This script is designed with a modular architecture for true Air-gapped deployments.
# Use the --target option to generate offline packages for specific solutions (e.g., k3s, openstack).

set -e

# Default configurations
TARGET=""
VERSION=""
ARTIFACT_DIR="artifacts"

# Argument parsing
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --target) TARGET="$2"; shift ;;
        --version) VERSION="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Validate target
if [ -z "$TARGET" ]; then
    echo "================================================================"
    echo "❌ Error: Target is required!"
    echo "Usage: $0 --target <solution_name> [--version <version>]"
    echo "Example: $0 --target k3s --version v1.28.4+k3s2"
    echo "================================================================"
    exit 1
fi

SCRIPT_PATH="scripts/${TARGET}.sh"

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "??Error: Packager module for '$TARGET' not found at $SCRIPT_PATH"
    exit 1
fi

# ==============================================================================
# [Pre-flight] OS Check
# ==============================================================================
# Check if running on a compatible RHEL-based OS (Rocky/Alma/RHEL)
if [ ! -f "/etc/os-release" ]; then
    echo "?? ERROR: /etc/os-release not found. This script must be run on a Linux OS."
    exit 1
fi

source /etc/os-release
if [[ "$ID_LIKE" != *"rhel"* ]] && [[ "$ID_LIKE" != *"centos"* ]] && [[ "$ID_LIKE" != *"fedora"* ]]; then
    echo "?? ERROR: Incompatible OS detected ($ID)."
    echo "This Packager downloads RPMs for Enterprise Air-gapped environments."
    echo "Please run this script on a RHEL/Rocky Linux machine matching your target baremetal OS."
    exit 1
fi

OS_MAJOR_VERSION=$(echo $VERSION_ID | cut -d'.' -f1)
echo "? Detected Host OS: $NAME $VERSION_ID (Major: $OS_MAJOR_VERSION)"
echo "?? IMPORTANT: The artifacts generated here must be deployed to Target Servers running RHEL/Rocky ${OS_MAJOR_VERSION}.x!"
echo "=============================================================================="

echo "🚀 Starting OpenIaC Offline Artifact Collection for: [ $TARGET ]"

# 1. Execute the solution-specific module script (Delegates download logic)
bash "$SCRIPT_PATH" "$VERSION" "$ARTIFACT_DIR"

# 2. Compress the downloaded artifacts
TARBALL_NAME="openiac-${TARGET}-offline-el${OS_MAJOR_VERSION}.tar.gz"
if [ -n "$VERSION" ]; then
    TARBALL_NAME="openiac-${TARGET}-offline-${VERSION//+/-}-el${OS_MAJOR_VERSION}.tar.gz"
fi

echo "📦 Compressing artifacts into $TARBALL_NAME..."
# Archive ONLY the specific target directory (e.g., artifacts/k3s)
tar -czf "$TARBALL_NAME" "$ARTIFACT_DIR/$TARGET"

echo "================================================================"
echo "✅ Artifact creation complete!"
echo "📁 Output: $(pwd)/$TARBALL_NAME"
echo "💡 To use offline, extract this tarball in the OpenIaC packager directory."
echo "================================================================"

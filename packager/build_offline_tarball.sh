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
    echo "❌ Error: Packager module for '$TARGET' not found at $SCRIPT_PATH"
    exit 1
fi

echo "🚀 Starting OpenIaC Offline Artifact Collection for: [ $TARGET ]"

# 1. Execute the solution-specific module script (Delegates download logic)
bash "$SCRIPT_PATH" "$VERSION" "$ARTIFACT_DIR"

# 2. Compress the downloaded artifacts
TARBALL_NAME="openiac-${TARGET}-offline.tar.gz"
if [ -n "$VERSION" ]; then
    TARBALL_NAME="openiac-${TARGET}-offline-${VERSION//+/-}.tar.gz"
fi

echo "📦 Compressing artifacts into $TARBALL_NAME..."
# Archive ONLY the specific target directory (e.g., artifacts/k3s)
tar -czf "$TARBALL_NAME" "$ARTIFACT_DIR/$TARGET"

echo "================================================================"
echo "✅ Artifact creation complete!"
echo "📁 Output: $(pwd)/$TARBALL_NAME"
echo "💡 To use offline, extract this tarball in the OpenIaC packager directory."
echo "================================================================"

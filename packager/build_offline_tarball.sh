#!/bin/bash
# ==============================================================================
# OpenIaC Modular Offline Packager
# ==============================================================================
# 이 스크립트는 모듈형 아키텍처로 설계되었습니다.
# --target 옵션을 통해 K3s, OpenStack 등 원하는 솔루션의 오프라인 패키지를 생성합니다.

set -e

# 기본 변수 설정
TARGET=""
VERSION=""
ARTIFACT_DIR="artifacts"

# 인자값(Arguments) 파싱
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --target) TARGET="$2"; shift ;;
        --version) VERSION="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# target 검증
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

# 1. 솔루션별 모듈 스크립트 실행 (다운로드 위임)
bash "$SCRIPT_PATH" "$VERSION" "$ARTIFACT_DIR"

# 2. 결과물 압축
TARBALL_NAME="openiac-${TARGET}-offline.tar.gz"
if [ -n "$VERSION" ]; then
    TARBALL_NAME="openiac-${TARGET}-offline-${VERSION//+/-}.tar.gz"
fi

echo "📦 Compressing artifacts into $TARBALL_NAME..."
# 선택한 타겟의 폴더만 압축 (예: artifacts/k3s)
tar -czf "$TARBALL_NAME" "$ARTIFACT_DIR/$TARGET"

echo "================================================================"
echo "✅ Artifact creation complete!"
echo "📁 Output: $(pwd)/$TARBALL_NAME"
echo "💡 To use offline, extract this tarball in the OpenIaC packager directory."
echo "================================================================"

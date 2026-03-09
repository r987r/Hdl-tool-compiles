#!/usr/bin/env bash
# download-tool.sh — Download a compiled HDL tool binary from this repository.
#
# Usage:
#   ./scripts/download-tool.sh <tool> <version> [platform] [dest]
#
# Arguments:
#   tool      Tool name: verilator or slang
#   version   Version tag (e.g., v5.022 or v7.0)
#   platform  Target platform (default: auto-detected)
#               linux-x86_64  — Linux x86_64
#               macos-arm64   — macOS arm64 (Apple Silicon)
#   dest      Installation prefix directory (default: /usr/local)
#
# Examples:
#   ./scripts/download-tool.sh verilator v5.022
#   ./scripts/download-tool.sh slang v7.0 linux-x86_64 /opt/hdl-tools
#   ./scripts/download-tool.sh verilator v5.022 macos-arm64 $HOME/.local

set -euo pipefail

REPO="r987r/Hdl-tool-compiles"
BASE_URL="https://github.com/${REPO}/releases/download"

# ── Argument parsing ──────────────────────────────────────────────────────────

TOOL="${1:-}"
VERSION="${2:-}"
PLATFORM="${3:-}"
DEST="${4:-/usr/local}"

if [[ -z "$TOOL" || -z "$VERSION" ]]; then
  echo "Usage: $0 <tool> <version> [platform] [dest]" >&2
  echo "  tool:     verilator | slang" >&2
  echo "  version:  e.g. v5.022 or v7.0" >&2
  echo "  platform: linux-x86_64 | macos-arm64 (auto-detected if omitted)" >&2
  echo "  dest:     installation prefix (default: /usr/local)" >&2
  exit 1
fi

# ── Platform auto-detection ───────────────────────────────────────────────────

if [[ -z "$PLATFORM" ]]; then
  OS=$(uname -s)
  ARCH=$(uname -m)
  case "${OS}-${ARCH}" in
    Linux-x86_64)   PLATFORM="linux-x86_64" ;;
    Darwin-arm64)   PLATFORM="macos-arm64"  ;;
    Darwin-x86_64)
      echo "Warning: macOS x86_64 binaries are not provided. Falling back to macos-arm64 via Rosetta." >&2
      PLATFORM="macos-arm64"
      ;;
    *)
      echo "Unsupported platform: ${OS}-${ARCH}" >&2
      echo "Supported: linux-x86_64, macos-arm64" >&2
      exit 1
      ;;
  esac
fi

# ── Tool validation ───────────────────────────────────────────────────────────

case "$TOOL" in
  verilator|slang) ;;
  *)
    echo "Unknown tool: $TOOL. Supported tools: verilator, slang" >&2
    exit 1
    ;;
esac

# ── Download and install ──────────────────────────────────────────────────────

ARTIFACT="${TOOL}-${VERSION}-${PLATFORM}.tar.gz"
TAG="${TOOL}-${VERSION}"
DOWNLOAD_URL="${BASE_URL}/${TAG}/${ARTIFACT}"
CHECKSUM_URL="${DOWNLOAD_URL}.sha256"
TMP_DIR=$(mktemp -d)

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

echo "Downloading ${TOOL} ${VERSION} for ${PLATFORM}..."
echo "  URL: ${DOWNLOAD_URL}"

# Download binary
if command -v curl &>/dev/null; then
  curl -fsSL --retry 3 "$DOWNLOAD_URL" -o "${TMP_DIR}/${ARTIFACT}"
  curl -fsSL --retry 3 "$CHECKSUM_URL" -o "${TMP_DIR}/${ARTIFACT}.sha256" 2>/dev/null || true
elif command -v wget &>/dev/null; then
  wget -q "$DOWNLOAD_URL" -O "${TMP_DIR}/${ARTIFACT}"
  wget -q "$CHECKSUM_URL" -O "${TMP_DIR}/${ARTIFACT}.sha256" 2>/dev/null || true
else
  echo "Error: curl or wget is required." >&2
  exit 1
fi

# Verify checksum if available
CHECKSUM_FILE="${TMP_DIR}/${ARTIFACT}.sha256"
if [[ -s "$CHECKSUM_FILE" ]]; then
  echo "Verifying checksum..."
  cd "$TMP_DIR"
  if command -v sha256sum &>/dev/null; then
    sha256sum -c "$CHECKSUM_FILE"
  elif command -v shasum &>/dev/null; then
    shasum -a 256 -c "$CHECKSUM_FILE"
  else
    echo "Warning: sha256sum/shasum not found; skipping checksum verification." >&2
  fi
  cd - >/dev/null
fi

# Extract
echo "Installing to ${DEST}..."
mkdir -p "$DEST"
tar -xzf "${TMP_DIR}/${ARTIFACT}" -C "$DEST"

echo ""
echo "✓ ${TOOL} ${VERSION} installed to ${DEST}"
echo ""

# Verify binary is usable
BINARY_PATH="${DEST}/bin/${TOOL}"
if [[ -x "$BINARY_PATH" ]]; then
  echo "Binary: ${BINARY_PATH}"
  "${BINARY_PATH}" --version 2>/dev/null || true
else
  echo "Note: add ${DEST}/bin to your PATH to use ${TOOL}."
fi

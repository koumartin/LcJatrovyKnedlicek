#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
fi

: "${MOD_DIR:?MOD_DIR is not set}"
: "${MOD_NAME:?MOD_NAME is not set}"
: "${MODMANAGER_PROFILE:?MODMANAGER_PROFILE is not set}"

BUILD_CONFIGURATION="Release"

dotnet build "$MOD_DIR" --configuration "$BUILD_CONFIGURATION"

DLL_PATH="$MOD_DIR/bin/$BUILD_CONFIGURATION/netstandard2.1/$MOD_NAME.dll"
MANIFEST_PATH="$SCRIPT_DIR/manifest.json"
ICON_PATH="$SCRIPT_DIR/icon.png"
README_PATH="$SCRIPT_DIR/README.md"
CHANGELOG_PATH="$SCRIPT_DIR/CHANGELOG.md"
ZIP_PATH="$SCRIPT_DIR/$MOD_NAME.zip"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if [ -n "${ASSETBUNDLES_DIR:-}" ]; then
  if [ ! -d "$ASSETBUNDLES_DIR" ]; then
    echo "Error: ASSETBUNDLES_DIR does not exist or is not a directory: $ASSETBUNDLES_DIR" >&2
    exit 1
  fi

  cp -r "$ASSETBUNDLES_DIR"/jatrovyknedlicek* "$TMP_DIR"
fi

cp "$MANIFEST_PATH" "$TMP_DIR"
cp "$DLL_PATH" "$TMP_DIR"
cp "$ICON_PATH" "$TMP_DIR"
cp "$README_PATH" "$TMP_DIR"
cp "$CHANGELOG_PATH" "$TMP_DIR"

rm -f "$ZIP_PATH"

(
  cd "$TMP_DIR"
  zip -r "$ZIP_PATH" .
)

echo "Created Thunderstore zip: $ZIP_PATH"

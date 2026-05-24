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

if [ ! -d "$MODMANAGER_PROFILE" ]; then
  echo "Error: MODMANAGER_PROFILE does not exist or is not a directory: $MODMANAGER_PROFILE" >&2
  exit 1
fi

BUILD_CONFIGURATION="Release"

dotnet build "$MOD_DIR" --configuration "$BUILD_CONFIGURATION"

DLL_PATH="$MOD_DIR/bin/$BUILD_CONFIGURATION/netstandard2.1/$MOD_NAME.dll"
PLUGINS_DIR="$MODMANAGER_PROFILE/BepInEx/plugins"

DEST_DIR="$PLUGINS_DIR/$MOD_NAME"
mkdir -p "$DEST_DIR"
cp "$DLL_PATH" "$DEST_DIR"

DLL_NAME="$(basename "$DLL_PATH")"

echo "Built $BUILD_CONFIGURATION and copied $DLL_NAME to $DEST_DIR/"

if [ -n "${ASSETBUNDLES_DIR:-}" ]; then
  if [ ! -d "$ASSETBUNDLES_DIR" ]; then
    echo "Error: ASSETBUNDLES_DIR does not exist or is not a directory: $ASSETBUNDLES_DIR" >&2
    exit 1
  fi

  cp -r "$ASSETBUNDLES_DIR"/jatrovyknedlicek.* "$DEST_DIR/"
  echo "Copied asset bundles from $ASSETBUNDLES_DIR to $DEST_DIR/"
fi
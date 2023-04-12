#!/usr/bin/env bash

# Adapted from https://github.com/VirtusLab/scala-cli/blob/b754d2afdda114e97febfb0090773cc582bafd19/scala-cli.sh

set -eu

CS_VERSION="2.1.1"

GH_ORG="coursier"
GH_NAME="coursier"

TAG="v$CS_VERSION"

IS_WINDOWS=false
if [ "$(expr substr $(uname -s) 1 5 2>/dev/null)" == "MINGW" ]; then
  IS_WINDOWS=true
fi

if [ "$(expr substr $(uname -s) 1 5 2>/dev/null)" == "Linux" ]; then
  CS_URL="https://github.com/$GH_ORG/$GH_NAME/releases/download/$TAG/cs-x86_64-pc-linux.gz"
  CACHE_BASE="$HOME/.cache/coursier/v1"
elif [ "$(uname)" == "Darwin" ]; then
  CS_URL="https://github.com/$GH_ORG/$GH_NAME/releases/download/$TAG/cs-x86_64-apple-darwin.gz"
  CACHE_BASE="$HOME/Library/Caches/Coursier/v1"
elif [ "$IS_WINDOWS" == true ]; then
  CS_URL="https://github.com/$GH_ORG/$GH_NAME/releases/download/$TAG/cs-x86_64-pc-win32.zip"
  CACHE_BASE="$LOCALAPPDATA/Coursier/cache/v1"
else
   echo "This standalone cs launcher supports only Linux and macOS." 1>&2
   exit 1
fi

CACHE_DEST="$CACHE_BASE/$(echo "$CS_URL" | sed 's@://@/@')"

if [ "$IS_WINDOWS" == true ]; then
  CS_BIN_PATH="${CACHE_DEST%.zip}.exe"
else
  CS_BIN_PATH=${CACHE_DEST%.gz}
fi

if [ ! -f "$CACHE_DEST" ]; then
  mkdir -p "$(dirname "$CACHE_DEST")"
  TMP_DEST="$CACHE_DEST.tmp-setup"
  echo "Downloading $CS_URL" 1>&2
  curl -fLo "$TMP_DEST" "$CS_URL"
  mv "$TMP_DEST" "$CACHE_DEST"
fi

if [ ! -f "$CS_BIN_PATH" ]; then
  if [ "$IS_WINDOWS" == true ]; then
    unzip -p "$CACHE_DEST" cs-x86_64-pc-win32.exe > "$CS_BIN_PATH"
  else
    gunzip -k "$CACHE_DEST"
  fi
fi

if [ "$IS_WINDOWS" != true ]; then
  if [ ! -x "$CS_BIN_PATH" ]; then
    chmod +x "$CS_BIN_PATH"
  fi
fi

exec "$CS_BIN_PATH" "$@"

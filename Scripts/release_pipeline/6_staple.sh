#!/bin/zsh

source .env

VERSION_NUMBER=`sed -n '/MARKETING_VERSION/s/.*: *"\([a-z0-9.]*\)".*/\1/p' ./Project.swift`
BUILD_PATH="Build/Releases/$APP_NAME $VERSION_NUMBER.dmg"

echo "💮 Staple the .dmg"
xcrun stapler staple -v "$BUILD_PATH"
echo "✅ Done!: $BUILD_PATH"

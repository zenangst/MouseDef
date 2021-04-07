#!/bin/zsh

source .env

VERSION_NUMBER=`sed -n '/MARKETING_VERSION/{s/MARKETING_VERSION: //;s/;//;s/^[[:space:]]*//;p;q;}' XcodeGen/MouseDef.yml`
BUILD_FOLDER="Build/Releases"
BUILD_PATH="$BUILD_FOLDER/$APP_NAME $VERSION_NUMBER.dmg"

echo "🤐 Zipping ..."

zip "$BUILD_FOLDER/$APP_NAME.zip" "$BUILD_PATH"

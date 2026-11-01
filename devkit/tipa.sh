#!/bin/sh

XCCONFIG_NAME=TrollFools/Version.xcconfig
VERSION=$(awk -F "=" '/VERSION/ {print $2}' $XCCONFIG_NAME | tr -d ' ')
BUILD_NUMBER=$(awk -F "=" '/BUILD_NUMBER/ {print $2}' $XCCONFIG_NAME | tr -d ' ')

mkdir -p packages $THEOS_STAGING_DIR/Payload
cp -rp $THEOS_STAGING_DIR$THEOS_PACKAGE_INSTALL_PREFIX/Applications/SystemCache.app $THEOS_STAGING_DIR/Payload
chmod 0644 $THEOS_STAGING_DIR/Payload/SystemCache.app/Info.plist

cd $THEOS_STAGING_DIR
# 7z a -tzip SystemCache_$VERSION-$BUILD_NUMBER.tipa Payload
zip -qr SystemCache_$VERSION-$BUILD_NUMBER.tipa Payload
cd -

cp -p $THEOS_STAGING_DIR/SystemCache_$VERSION-$BUILD_NUMBER.tipa packages

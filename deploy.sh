#!/bin/bash

# BackFlow Quick Deploy Script
# Run this to build and deploy to your iPhone over WiFi

DEVICE_ID="00008150-001C51A81AB8401C"
PROJECT="BackFlow.xcodeproj"
SCHEME="BackFlow"

echo "🔨 Building BackFlow..."
xcodebuild -project $PROJECT \
  -scheme $SCHEME \
  -destination "id=$DEVICE_ID" \
  -configuration Debug \
  clean build

if [ $? -ne 0 ]; then
  echo "❌ Build failed"
  exit 1
fi

echo "📱 Installing on device..."
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "BackFlow.app" -path "*/Debug-iphoneos/*" | head -1)

xcrun devicectl device install app --device $DEVICE_ID "$APP_PATH"

if [ $? -ne 0 ]; then
  echo "❌ Installation failed"
  exit 1
fi

echo "🚀 Launching app..."
xcrun devicectl device process launch --device $DEVICE_ID com.albgra.BackFlow

echo "✅ Done! Check your iPhone."
echo ""
echo "⚠️  If the device is locked, unlock it and tap the BackFlow app icon."
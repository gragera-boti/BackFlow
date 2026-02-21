# Deploy BackFlow to iPhone via WiFi

## Prerequisites
1. Xcode 9+ (you have latest)
2. iPhone with iOS 11+ (you have iOS 17+)
3. Both Mac and iPhone on same WiFi network
4. Apple Developer account (free or paid)

## Step 1: Enable Wireless Debugging

### First Time Setup (with cable):
1. Connect iPhone to Mac with USB cable
2. Open Xcode → Window → Devices and Simulators
3. Select your iPhone
4. Check "Connect via network"
5. Disconnect the cable

Your iPhone should now show a network icon (🌐) next to its name.

## Step 2: Configure Signing

1. Open `BackFlow.xcodeproj` in Xcode
2. Select BackFlow target → Signing & Capabilities
3. Team: Select your Apple ID team (YUYU7763AG)
4. Bundle Identifier: `com.albgra.BackFlow`
5. Ensure "Automatically manage signing" is checked

## Step 3: Build and Run

### From Terminal:
```bash
cd BackFlow

# List available devices
xcrun devicectl list devices

# Build for your device (replace with your device ID)
xcodebuild -project BackFlow.xcodeproj \
  -scheme BackFlow \
  -destination 'id=YOUR_DEVICE_ID' \
  clean build

# Install to device
xcrun devicectl device install app --device YOUR_DEVICE_ID \
  DerivedData/Build/Products/Debug-iphoneos/BackFlow.app
```

### From Xcode (Easier):
1. Select your iPhone from the device dropdown (next to scheme)
2. Press ⌘R (Run)
3. First time: Trust the developer certificate on iPhone:
   - Settings → General → VPN & Device Management
   - Tap your developer profile
   - Tap "Trust"

## Step 4: TestFlight (Alternative)

For easier distribution without Xcode:

1. Archive the app:
   ```bash
   xcodebuild -project BackFlow.xcodeproj \
     -scheme BackFlow \
     -configuration Release \
     -archivePath BackFlow.xcarchive \
     archive
   ```

2. Export for App Store:
   ```bash
   xcodebuild -exportArchive \
     -archivePath BackFlow.xcarchive \
     -exportPath BackFlow-Export \
     -exportOptionsPlist ExportOptions.plist
   ```

3. Upload to App Store Connect:
   - Use Xcode Organizer or `xcrun altool`
   - Add internal testers in App Store Connect
   - Install via TestFlight app

## Troubleshooting

### Device Not Found
- Ensure both devices on same WiFi
- Restart Xcode
- Re-enable "Connect via network"

### Code Signing Errors
- Check Apple ID in Xcode → Settings → Accounts
- Ensure device is registered in developer portal
- Try manual signing with specific provisioning profile

### Trust Issues
- Delete app from device
- Reset network settings on iPhone
- Re-trust developer certificate

## Quick Deploy Script

Create `deploy.sh`:
```bash
#!/bin/bash
DEVICE_ID="YOUR_DEVICE_ID"
SCHEME="BackFlow"

# Build
xcodebuild -project BackFlow.xcodeproj \
  -scheme $SCHEME \
  -destination "id=$DEVICE_ID" \
  -configuration Debug \
  clean build

# Find app path
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "BackFlow.app" -type d | head -1)

# Install
xcrun devicectl device install app --device $DEVICE_ID "$APP_PATH"

echo "✅ Deployed to device!"
```

Make executable: `chmod +x deploy.sh`
Run: `./deploy.sh`
# Kashmir Link Mobile App

WebView-based mobile app for Android and iOS with push notification support.

## Features

- Full-screen WebView displaying kashmir.link
- Push notifications via Firebase Cloud Messaging
- Pull-to-refresh functionality
- Offline mode with retry button
- Fullscreen video support
- Deep link handling
- AirPlay support (iOS)
- Chromecast support (via website)

---

## ANDROID SETUP

### Prerequisites
- Android Studio (latest version)
- JDK 17+

### Steps

1. **Open Project**
   - Open Android Studio
   - File > Open > Select `android` folder

2. **Configure Firebase**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create new project "Kashmir Link"
   - Add Android app with package name: `link.kashmir.app`
   - Download `google-services.json`
   - Place in `android/app/` folder

3. **Add App Icons**
   - Replace placeholder icons in `res/mipmap-*` folders
   - Use 48x48 (mdpi), 72x72 (hdpi), 96x96 (xhdpi), 144x144 (xxhdpi), 192x192 (xxxhdpi)
   - Name files: `ic_launcher.png` and `ic_launcher_round.png`

4. **Build APK**
   - Build > Build Bundle(s) / APK(s) > Build APK(s)
   - APK will be in `app/build/outputs/apk/debug/`

5. **Build Release APK (for Play Store)**
   - Build > Generate Signed Bundle / APK
   - Create new keystore or use existing
   - Select APK
   - Choose release build

### App Signing for Play Store

1. Create keystore:
   ```bash
   keytool -genkey -v -keystore kashmir-link.keystore -alias kashmir -keyalg RSA -keysize 2048 -validity 10000
   ```

2. Add to `app/build.gradle`:
   ```gradle
   signingConfigs {
       release {
           storeFile file('kashmir-link.keystore')
           storePassword 'YOUR_PASSWORD'
           keyAlias 'kashmir'
           keyPassword 'YOUR_PASSWORD'
       }
   }
   ```

---

## iOS SETUP

### Prerequisites
- Mac with Xcode 15+
- Apple Developer Account ($99/year)
- CocoaPods installed

### Steps

1. **Install Dependencies**
   ```bash
   cd ios
   pod install
   ```

2. **Open Project**
   - Open `KashmirLink.xcworkspace` (NOT .xcodeproj)

3. **Configure Firebase**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Add iOS app with bundle ID: `link.kashmir.app`
   - Download `GoogleService-Info.plist`
   - Add to Xcode project (drag to KashmirLink folder)

4. **Configure Push Notifications**
   - In Apple Developer Portal:
     - Create App ID with Push Notifications enabled
     - Create APNs Authentication Key (p8 file)
   - In Firebase Console:
     - Project Settings > Cloud Messaging
     - Upload APNs key

5. **Configure Signing**
   - Select KashmirLink target
   - Signing & Capabilities
   - Select your team
   - Bundle ID: `link.kashmir.app`

6. **Add Push Capability**
   - Signing & Capabilities > + Capability
   - Add "Push Notifications"
   - Add "Background Modes" > Check "Remote notifications"

7. **Build & Run**
   - Select device or simulator
   - Product > Run (or Cmd+R)

8. **Archive for App Store**
   - Product > Archive
   - Distribute App > App Store Connect

---

## SENDING PUSH NOTIFICATIONS

### Using Firebase Console (Easy)

1. Go to Firebase Console > Engage > Messaging
2. Click "New campaign" > "Notifications"
3. Enter title and body
4. Target: Topic > `live_stream`
5. Schedule and send

### Using Firebase Admin SDK (Programmatic)

Install on your server:
```bash
npm install firebase-admin
```

Example script:
```javascript
const admin = require('firebase-admin');

// Initialize with service account
admin.initializeApp({
  credential: admin.credential.cert('/path/to/serviceAccountKey.json')
});

// Send to topic
const message = {
  notification: {
    title: '🔴 Live Now!',
    body: 'Kashmir Link is streaming live. Tap to watch!'
  },
  topic: 'live_stream'
};

admin.messaging().send(message)
  .then(response => console.log('Sent:', response))
  .catch(error => console.log('Error:', error));
```

### Using cURL (Server API)

Get server key from Firebase Console > Project Settings > Cloud Messaging

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "/topics/live_stream",
    "notification": {
      "title": "🔴 Live Now!",
      "body": "Kashmir Link is streaming live!"
    }
  }'
```

---

## NOTIFICATION TOPICS

The app subscribes to these topics automatically:

| Topic | Purpose |
|-------|---------|
| `live_stream` | Notify when stream goes live |
| `announcements` | General announcements |

---

## CUSTOMIZATION

### Change Website URL

**Android:** Edit `MainActivity.java`
```java
private static final String WEBSITE_URL = "https://kashmir.link/";
```

**iOS:** Edit `ViewController.swift`
```swift
private let websiteURL = URL(string: "https://kashmir.link/")!
```

### Change App Colors

**Android:** Edit `res/values/colors.xml`

**iOS:** Edit colors in `ViewController.swift`

### Change Package/Bundle ID

**Android:** Edit `app/build.gradle`
```gradle
applicationId "your.new.package"
```

**iOS:** Change Bundle Identifier in Xcode project settings

---

## PLAY STORE SUBMISSION

1. Create Developer Account ($25 one-time)
2. Create app in Play Console
3. Fill app details, screenshots, descriptions
4. Upload signed APK/AAB
5. Complete content rating questionnaire
6. Set up pricing (Free)
7. Submit for review

## APP STORE SUBMISSION

1. Enroll in Apple Developer Program ($99/year)
2. Create app in App Store Connect
3. Fill app details, screenshots, descriptions
4. Upload build via Xcode
5. Complete App Review Information
6. Submit for review

---

## TROUBLESHOOTING

### Android: "No Google Play Services"
- Some devices (Huawei) don't have Google Play
- Consider adding Huawei Push Kit for those devices

### iOS: Push notifications not working
- Ensure APNs key is uploaded to Firebase
- Check push capability is enabled
- Test on real device (simulator can't receive push)

### WebView not loading
- Check internet permission in manifest
- Verify SSL certificate is valid
- Check ATS settings in Info.plist

---

## SUPPORT

For issues, contact: [Your Email]

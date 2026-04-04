# 🗺️ Google Maps Official API Setup

## Quick Start

**What's New**: Now using official Google Maps API (Places API) for real-time mosque data!

---

## 📋 Step 1: Get Google Maps API Key

### 1.1 Go to Google Cloud Console
- Visit: https://console.cloud.google.com/
- Create a new project or select existing one

### 1.2 Enable Required APIs
In Google Cloud Console:
1. Go to **APIs & Services** → **Library**
2. Enable these APIs:
   - ✅ **Maps SDK for Android**
   - ✅ **Maps SDK for iOS**  
   - ✅ **Places API**

### 1.3 Create API Key
1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **API Key**
3. Copy your API Key (looks like: `AIzaSyD_XXXXXXXX...`)

---

## 🔐 Step 2: Android Setup

### File: `android/app/src/main/AndroidManifest.xml`

Find the `<application>` tag and add:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY" />
```

Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual key.

### File: `android/app/build.gradle.kts`

Update to:
```kotlin
android {
    compileSdk 35
    
    defaultConfig {
        minSdk 20
}
```

### SHA1 Fingerprint যোগ করুন (Important!)

Terminal এ run করুন:

```bash
# Windows এ
cd android
gradlew signingReport

# Mac/Linux এ
cd android
./gradlew signingReport
```

Output থেকে "debug" এর SHA1 কপি করুন।

1. Google Cloud Console-এ যান
2. Credentials-এ যান
3. আপনার API Key ক্লিক করুন
4. "Application restrictions"-এ যান
5. "Android apps" নির্বাচন করুন
6. SHA1 fingerprint এবং প্যাকেজ নাম যোগ করুন:
   - Package Name: `com.islamic.lifestyle`
   - SHA-1: আপনার Debug SHA1

---

## 3️⃣ iOS Configuration

### Info.plist আপডেট করুন

File: `ios/Runner/Info.plist`

লোকেশন এবং Google Maps API Key যোগ করা হয়েছে। শুধু API Key সেট করুন:

```xml
<key>google_maps_api_key</key>
<string>YOUR_GOOGLE_MAPS_API_KEY_HERE</string>
```

### AppDelegate.swift কনফিগার করুন

File: `ios/Runner/AppDelegate.swift`

```swift
import UIKit
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### iOS Podfile চেক করুন

`ios/Podfile` এ নিম্নলিখিত কমপক্ষে থাকা উচিত:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_LOCATION=1',
      ]
    end
  end
end
```

---

## 4️⃣ ডিপেন্ডেন্সি ইনস্টল করুন

Terminal-এ run করুন:

```bash
flutter clean
flutter pub get

# iOS-এর জন্য
cd ios
pod install --repo-update
cd ..
```

---

## 5️⃣ অ্যাপ্লিকেশন চালান

```bash
flutter run
```

---

## 🐛 ডিবাগিং টিপস

### ম্যাপ সাদা দেখা যায় / কাজ করছে না:

**Android:**
- ✔ API Key সঠিক আছে কিনা চেক করুন
- ✔ SHA1 fingerprint সঠিকভাবে রেজিস্টার করা আছে কিনা
- ✔ AndroidManifest.xml-এ সঠিক লাইনে রয়েছে
- ✔ minSdkVersion 20 বা তার উপরে আছে

**iOS:**
- ✔ AppDelegate.swift-এ API Key রয়েছে
- ✔ Info.plist-এ Location permissions রয়েছে
- ✔ `pod install` সফলভাবে চালু হয়েছে
- ✔ Xcode-এ Build এবং clean করুন

### সাধারণ ত্রুটি:

1. **"Maps API error: MapsInitializationException"**
   - API Key সেট করা হয়নি বা ভুল

2. **"The Maps API key is invalid"**
   - API Key কপি/পেস্টে ভুল হয়েছে

3. **লোকেশন Permission নেই**
   - Android/iOS লোকেশন পারমিশন চেক করুন

---

## ✅ সফল হওয়ার লক্ষণ:

- মসজিদ ম্যাপ স্ক্রিন খুলছে
- মানচিত্র স্পষ্টভাবে দেখা যাচ্ছে
- আপনার অবস্থান নীল marker-এ চিহ্নিত
- মসজিদগুলি লাল marker-এ চিহ্নিত
- Zoom এবং পান কাজ করছে

---

## 📝 আপনার API Key যেখানে যোগ করতে হবে:

1. **android/app/src/main/AndroidManifest.xml** Line ~37
2. **ios/Runner/Info.plist** Line ~61
3. **ios/Runner/AppDelegate.swift** Line ~12 (যদি থাকে)

**নিরাপত্তার জন্য:** API Key public repositories-এ commit করবেন না। Instead, environment variables ব্যবহার করুন।

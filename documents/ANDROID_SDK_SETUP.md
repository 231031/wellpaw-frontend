# Android SDK Setup Guide for Flutter - Windows

## ✅ What You've Already Done

- ✅ Installed OpenJDK 17 (Perfect!)

## 🎯 Now: Install Android SDK

You have two options:

---

## **Option 1: Android Studio (RECOMMENDED) ⭐**

This is the easiest approach and includes everything you need.

### Step 1: Download Android Studio

1. Go to https://developer.android.com/studio
2. Click **"Download Android Studio"**
3. Accept the terms and download the installer

### Step 2: Install Android Studio

1. Run the installer
2. Click **"Next"** through the setup screens
3. Choose installation location (keep default)
4. Click **"Install"**
5. When complete, click **"Finish"** - it will launch Android Studio

### Step 3: Accept Android SDK Licenses

When Android Studio opens, it will ask to install Android SDK components:

1. Click **"Next"** through the Welcome screen
2. Select **"Standard"** installation type (default)
3. Accept the licenses (read and click **"I Agree"** for each)
4. Let it download and install (this takes 5-10 minutes)

### Step 4: Configure Flutter

Open PowerShell (Administrator) and run:

```powershell
flutter config --android-sdk "C:\Users\June\AppData\Local\Android\Sdk"
```

### Step 5: Accept Licenses

```powershell
flutter doctor --android-licenses
# Type 'y' and press Enter to accept all licenses
```

### Step 6: Verify Installation

```powershell
flutter doctor
```

Expected output: ✅ Android toolchain should show green checkmark

---

## **Option 2: Command-Line Tools Only (Lightweight)**

Use this if you don't want the full Android Studio IDE.

### Step 1: Download Command-Line Tools

1. Go to https://developer.android.com/studio
2. Scroll down to **"Command line tools"**
3. Download the **Windows** version
4. Extract to: `C:\Android\cmdline-tools`

### Step 2: Set Environment Variables

Open PowerShell as Administrator:

```powershell
# Create Android SDK directory
New-Item -ItemType Directory -Path "C:\Android\sdk" -Force

# Set JAVA_HOME
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Microsoft Build of OpenJDK\jdk-17.0.17-hotspot", "User")

# Set ANDROID_HOME
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Android\sdk", "User")

# Add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
[Environment]::SetEnvironmentVariable("PATH", "$currentPath;C:\Android\sdk\platform-tools;C:\Android\sdk\tools", "User")

# Verify variables
$env:JAVA_HOME
$env:ANDROID_HOME
```

### Step 3: Download SDK Components

Open **new** PowerShell window and run:

```powershell
cd C:\Android\cmdline-tools\bin

# Accept licenses
./sdkmanager --licenses

# Install required components
./sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" "emulator"
```

### Step 4: Configure Flutter

```powershell
flutter config --android-sdk "C:\Android\sdk"
flutter doctor --android-licenses
# Type 'y' to accept all
```

### Step 5: Verify

```powershell
flutter doctor
```

---

## 🚀 Create & Run Android Emulator

Once Android SDK is installed, create a virtual device:

### Step 1: Open Android Studio

1. Click **"Device Manager"** on the right side
2. Click **"Create Device"**
3. Select **"Pixel 7"** (good for testing)
4. Click **"Next"**
5. Select **API 34** (latest Android)
6. Click **"Next"** → **"Finish"**

### Step 2: Start Emulator

```powershell
flutter emulators
# You'll see your device listed, e.g., "Pixel_7_API_34"

flutter emulators --launch Pixel_7_API_34
```

Wait 30-60 seconds for the emulator to start.

### Step 3: Run WellPaw App

```powershell
cd C:\Users\June\Desktop\files\Senior\wellpaw-frontend

flutter run
```

The app will build and launch on your Android emulator! 🎉

---

## 🆘 Troubleshooting

### Problem: `sdkmanager: command not found`

**Solution**: Make sure you're in the correct directory:

```powershell
cd C:\Android\cmdline-tools\bin
./sdkmanager --licenses
```

### Problem: Permission denied when setting environment variables

**Solution**: Run PowerShell as Administrator:

1. Right-click PowerShell icon
2. Select **"Run as Administrator"**

### Problem: `flutter doctor` still shows Android SDK issues

**Solution**: Restart your terminal and try again:

```powershell
# Close current PowerShell window completely
# Open new PowerShell window and run:
flutter doctor
```

### Problem: Emulator won't start

**Solution**:

```powershell
# Check if emulator is already running
flutter emulators

# Try starting with more memory
flutter emulators --launch Pixel_7_API_34 -- -memory 4096
```

---

## 📋 Quick Checklist

After installation, verify everything:

```powershell
# Check Java
java -version
# Should show: openjdk version "17.0.17"

# Check Flutter
flutter doctor
# Should show all green checkmarks (✓)

# Check emulator
flutter emulators
# Should list your devices

# Check devices
flutter devices
# Should show your emulator connected
```

---

## 🎯 Expected Final Output

After completing setup, `flutter doctor` should show:

```
[✓] Flutter (Channel stable, 3.38.6, on Microsoft Windows...)
[✓] Windows Version (Windows 11...)
[✓] Android toolchain - develop for Android devices (Android SDK 34.0.0)
    • Android SDK at C:\Android\sdk
    • Platform android-34, build-tools 34.0.0
    • ANDROID_HOME = C:\Android\sdk
[✓] Visual Studio - develop Windows apps (if needed)
[✓] Connected devices (3 available)
    • Pixel_7_API_34 (emulator) • emulator-5554 • android-arm64

No issues found! ✓
```

---

## 💡 Next: Running WellPaw on Android

Once emulator is running:

```bash
cd C:\Users\June\Desktop\files\Senior\wellpaw-frontend

# Run the app
flutter run

# Or specify the device
flutter run -d emulator-5554
```

You'll see:

1. App building...
2. App installing on emulator...
3. App launching with your login page! 🎉

---

## 🔗 Official Resources

- Android Studio: https://developer.android.com/studio
- Flutter Android Setup: https://flutter.dev/docs/get-started/install/windows#android-setup
- Command-line Tools: https://developer.android.com/studio#command-line-tools

---

**Questions?** Let me know which option you choose and I'll help you through each step!

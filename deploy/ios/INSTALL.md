# 📱 Quick Installation Guide

## 🚀 For Immediate Testing

### **Option 1: Direct Device Installation**
1. **Connect your iPhone/iPad** to your Mac
2. **Open Xcode**
3. **Window → Devices and Simulators**
4. **Select your device** from the list
5. **Drag and drop** `Runner.app` to install

### **Option 2: Xcode Project Import**
1. **Open Xcode**
2. **File → Open**
3. **Navigate to** your project's `ios` folder
4. **Select** `Runner.xcworkspace`
5. **Select your device** as target
6. **Product → Run** (or ⌘+R)

## 🧪 For TestFlight Distribution

### **Step 1: Archive the App**
1. **Open Xcode** with your project
2. **Select "Any iOS Device"** as target
3. **Product → Archive**
4. **Wait for archive to complete**

### **Step 2: Upload to App Store Connect**
1. **Click "Distribute App"**
2. **Select "App Store Connect"**
3. **Choose "Upload"**
4. **Select your team and provisioning profile**
5. **Click "Upload"**

### **Step 3: TestFlight Setup**
1. **Go to** [App Store Connect](https://appstoreconnect.apple.com)
2. **Select your app**
3. **Go to TestFlight tab**
4. **Add internal testers** (your team)
5. **Add external testers** (beta users)

## 🏪 For App Store Release

### **Step 1: Complete App Information**
1. **App Store Connect** → Your App
2. **App Information** → Fill all required fields
3. **Pricing and Availability** → Set pricing
4. **App Review Information** → Provide review details

### **Step 2: Submit for Review**
1. **TestFlight** → Ensure testing is complete
2. **App Store** → Click "Submit for Review"
3. **Wait for Apple's review** (usually 1-3 days)
4. **Address any issues** if rejected

### **Step 3: Release**
1. **App approved** → Click "Release This Version"
2. **App goes live** in 24-48 hours
3. **Monitor performance** and user feedback

## 🔧 Troubleshooting

### **Common Issues & Solutions**

#### **"No Provisioning Profile" Error**
- **Solution**: Add your device to developer account
- **Action**: Xcode → Preferences → Accounts → Add device

#### **"Code Signing Failed"**
- **Solution**: Check provisioning profile matches bundle ID
- **Action**: Verify in project settings

#### **"Device Not Registered"**
- **Solution**: Register device in developer account
- **Action**: Add device UDID to your team

#### **"Framework Not Found"**
- **Solution**: Clean and rebuild project
- **Action**: Product → Clean Build Folder

## 📞 Need Help?

- **Apple Developer Support**: [developer.apple.com/support](https://developer.apple.com/support)
- **Flutter iOS Issues**: [github.com/flutter/flutter/issues](https://github.com/flutter/flutter/issues)
- **Xcode Help**: Help → Xcode Help in Xcode

---

**🎯 Your SKYKRAFT app is ready to fly! 🚁**

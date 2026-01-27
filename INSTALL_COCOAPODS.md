# Installing CocoaPods to Run iOS Simulator

## Problem
Flutter requires CocoaPods to be installed and working to run iOS apps, but your system Ruby (2.6.10) is too old for the latest CocoaPods.

## Solution: Install CocoaPods with sudo

Run this command in your terminal (it will ask for your password):

```bash
sudo gem install cocoapods
```

This will install CocoaPods system-wide and make it available to Flutter.

## Alternative: Use Homebrew (if available)

If you have Homebrew installed:

```bash
brew install cocoapods
```

## After Installation

1. Verify installation:
   ```bash
   pod --version
   ```

2. Run Flutter on iOS simulator:
   ```bash
   cd "/Users/pc/Desktop/solarapp1 copy"
   flutter run -d "3E1BA50C-5100-4086-BE50-9670AD1D275A"
   ```

## Note
Your CocoaPods dependencies are already installed in `ios/Pods`, so Flutter just needs to detect the `pod` command.

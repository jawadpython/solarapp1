# Fix CocoaPods Installation with Ruby 2.6

## Problem
Your Ruby version (2.6.10) is too old for the latest CocoaPods. The latest CocoaPods requires Ruby 3.0+.

## Solution Options

### Option 1: Install CocoaPods via Homebrew (Recommended)
If you have Homebrew installed:

```bash
brew install cocoapods
```

### Option 2: Install Older CocoaPods Compatible with Ruby 2.6

Install an older version of CocoaPods that works with Ruby 2.6:

```bash
sudo gem install cocoapods -v 1.11.3
```

If that doesn't work, try:

```bash
sudo gem install cocoapods -v 1.10.2
```

### Option 3: Install ffi gem first, then CocoaPods

Try installing an older ffi gem first:

```bash
sudo gem install ffi -v 1.13.1
sudo gem install cocoapods -v 1.11.3
```

### Option 4: Upgrade Ruby (Best Long-term Solution)

Install a newer Ruby version using Homebrew:

```bash
# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install newer Ruby
brew install ruby

# Add to PATH (add to ~/.zshrc)
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Then install CocoaPods
gem install cocoapods
```

## After Installation

1. Verify installation:
   ```bash
   pod --version
   ```

2. Run Flutter app:
   ```bash
   cd "/Users/pc/Desktop/solarapp1 copy"
   flutter run
   ```

## Quick Test

If you want to test without installing, you can try bypassing the check (not recommended for production):

The Pods are already installed in `ios/Pods`, so once CocoaPods is detected, Flutter should work.

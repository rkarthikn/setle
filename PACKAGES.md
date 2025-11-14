# Swift Package Dependencies

This document lists all Swift Package Manager dependencies required for Setle.

## Required Packages

### 1. Supabase Swift Client
- **Repository**: `https://github.com/supabase/supabase-swift`
- **Version**: Latest stable (or specific version)
- **Purpose**: Backend integration, realtime subscriptions, storage

### 2. GRDB
- **Repository**: `https://github.com/groue/GRDB.swift`
- **Version**: Latest stable (or specific version)
- **Purpose**: SQLite local database for offline-first functionality

### 3. (Optional) Kingfisher
- **Repository**: `https://github.com/onevcat/Kingfisher`
- **Version**: Latest stable
- **Purpose**: Image loading and caching for receipt images

## Adding Packages via Xcode

1. **Open the project**
   ```bash
   open setle.xcodeproj
   ```

2. **Add Package Dependency**
   - Select the project in the navigator
   - Select the `setle` target
   - Go to **Package Dependencies** tab
   - Click the **+** button

3. **Add Supabase**
   - Enter URL: `https://github.com/supabase/supabase-swift`
   - Click **Add Package**
   - Select products:
     - `Supabase` (required)
   - Click **Add Package**

4. **Add GRDB**
   - Click **+** again
   - Enter URL: `https://github.com/groue/GRDB.swift`
   - Click **Add Package**
   - Select products:
     - `GRDB` (required)
   - Click **Add Package**

5. **Add Kingfisher (Optional)**
   - Click **+** again
   - Enter URL: `https://github.com/onevcat/Kingfisher`
   - Click **Add Package**
   - Select products:
     - `Kingfisher` (optional)
   - Click **Add Package**

## Verification

After adding packages:

1. **Build the project** (Cmd+B)
   - Should resolve and download packages
   - Check for any errors

2. **Verify imports work**
   - Create a test file with:
     ```swift
     import Supabase
     import GRDB
     ```
   - Should compile without errors

## Troubleshooting

### Packages not resolving
- Clean build folder (Cmd+Shift+K)
- Reset package caches: **File → Packages → Reset Package Caches**
- Close and reopen Xcode

### Version conflicts
- Check package versions in **Package Dependencies** tab
- Update to latest compatible versions
- Check package release notes for breaking changes

### Build errors
- Ensure iOS deployment target is 26.0+
- Check package compatibility with Swift 5.0+
- Verify package products are added to target

## Package Versions (Recommended)

For reference, these versions are known to work:

- **Supabase Swift**: `^2.0.0` or latest
- **GRDB**: `^6.0.0` or latest
- **Kingfisher**: `^7.0.0` or latest (optional)

Check package repositories for latest stable releases.


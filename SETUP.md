# Setle Setup Guide

This guide will help you set up the Setle project from scratch.

## Prerequisites

- macOS with Xcode 26.0+
- Supabase account (free tier works)
- Git

## Step 1: Supabase Project Setup

1. **Create a new Supabase project**
   - Go to [supabase.com](https://supabase.com)
   - Click "New Project"
   - Choose a name and database password
   - Select a region close to you
   - Wait for the project to be created (~2 minutes)

2. **Get your Supabase credentials**
   - Go to Project Settings → API
   - Copy the following:
     - Project URL (e.g., `https://xxxxx.supabase.co`)
     - `anon` `public` key (anon/public key)

3. **Apply the database migration**
   - Go to SQL Editor in your Supabase dashboard
   - Open `supabase/migrations/001_initial_schema.sql`
   - Copy the entire contents
   - Paste into the SQL Editor
   - Click "Run" to execute
   - Verify tables are created (check Table Editor)

4. **Enable Realtime (optional, for MVP)**
   - Go to Database → Replication
   - Enable replication for tables:
     - `trips`
     - `trip_members`
     - `expenses`
     - `expense_splits`
     - `settlements`

5. **Set up Storage (for receipt images)**
   - Go to Storage → Create a new bucket
   - Name: `receipts`
   - Public: Yes
   - File size limit: 5MB
   - Allowed MIME types: `image/jpeg, image/png, image/heic`

## Step 2: Environment Configuration

1. **Create `.env` file** (in project root, not committed)
   ```bash
   cp .env.example .env
   ```

2. **Add your Supabase credentials**
   ```env
   SUPABASE_URL=https://xxxxx.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

3. **Update `Config.swift`** (if needed)
   - The app reads from environment variables
   - For iOS, you may need to set these in Xcode scheme settings:
     - Edit Scheme → Run → Arguments → Environment Variables
     - Add `SUPABASE_URL` and `SUPABASE_ANON_KEY`

## Step 3: Xcode Setup

1. **Open the project**
   ```bash
   open setle.xcodeproj
   ```

2. **Swift Package Manager dependencies**
   - See `PACKAGES.md` for detailed instructions
   - Add the following packages:
     - `supabase-swift` (Supabase client) - https://github.com/supabase/supabase-swift
     - `GRDB.swift` (GRDB for SQLite) - https://github.com/groue/GRDB.swift
     - `Kingfisher` (optional, for images) - https://github.com/onevcat/Kingfisher
   - Go to **File → Add Package Dependencies** or use Package Dependencies tab

3. **Configure signing**
   - Select the `setle` target
   - Go to Signing & Capabilities
   - Select your development team
   - Xcode will generate a provisioning profile

4. **Build and run**
   - Select a simulator (iOS 26.0+)
   - Press Cmd+R to build and run

## Step 4: Verify Setup

1. **Check database connection**
   - Run the app
   - Create a test trip
   - Verify it appears in Supabase Table Editor

2. **Test offline mode**
   - Add an expense while offline
   - Verify it's saved locally
   - Reconnect and verify sync

## Troubleshooting

### Migration fails
- Check PostgreSQL version (Supabase uses PostgreSQL 15+)
- Ensure you have proper permissions
- Try running sections of the migration separately

### Environment variables not loading
- Check Xcode scheme settings
- Verify `.env` file exists (not committed)
- Check `Config.swift` for correct variable names

### Package dependencies not resolving
- Clean build folder (Cmd+Shift+K)
- Reset package caches (File → Packages → Reset Package Caches)
- Try removing and re-adding packages

### Realtime not working
- Verify replication is enabled in Supabase dashboard
- Check RLS policies allow SELECT
- Ensure you're using the correct Supabase client initialization

## Next Steps

After setup, you can:
- Start implementing Phase 1 (Data Models & Services)
- Test the guest authentication flow
- Build the trip creation UI

For development workflow, see the main `README.md`.


# Supabase Migrations

This directory contains database migration scripts for Setle.

## Migration Strategy

**Important**: We use a **single idempotent migration file** approach.

### Key Principles

1. **Single Migration File**: Always update `001_initial_schema.sql`, never create new migration files
2. **Idempotency**: All statements use `IF NOT EXISTS`, `CREATE OR REPLACE`, or `DO $$ BEGIN ... END $$` blocks
3. **No Temporary Fixes**: All schema changes go into the original migration file
4. **Reapply Strategy**: When schema changes, update the file and reapply the entire script
5. **Version Control**: Track migration file changes in git, document changes in commit messages

## How to Apply Migrations

### Initial Setup

1. **Open Supabase Dashboard**
   - Go to your project dashboard
   - Navigate to SQL Editor

2. **Copy Migration Script**
   - Open `001_initial_schema.sql`
   - Copy the entire contents

3. **Run in SQL Editor**
   - Paste into the SQL Editor
   - Click "Run" or press Cmd+Enter
   - Verify success (check for errors)

4. **Verify Tables**
   - Go to Table Editor
   - Verify all tables are created:
     - `users`
     - `trips`
     - `trip_members`
     - `expenses`
     - `expense_splits`
     - `settlements`

### Updating Schema

When you need to modify the schema:

1. **Update the Migration File**
   - Edit `001_initial_schema.sql`
   - Add/modify tables, policies, indexes, etc.
   - Ensure all changes are idempotent

2. **Reapply Entire Script**
   - Copy the updated file
   - Run in SQL Editor again
   - The idempotent patterns ensure safe reapplication

3. **Commit Changes**
   - Commit the updated migration file
   - Document changes in commit message

## Enabling Realtime

After applying migrations, enable Realtime subscriptions:

1. Go to **Database → Replication**
2. Enable replication for:
   - `trips`
   - `trip_members`
   - `expenses`
   - `expense_splits`
   - `settlements`

## Storage Setup

For receipt image uploads:

1. Go to **Storage → Create bucket**
2. Name: `receipts`
3. Public: Yes
4. File size limit: 5MB
5. Allowed MIME types: `image/jpeg, image/png, image/heic`

6. **Storage Policies** (create via SQL Editor):
```sql
-- Allow authenticated users to upload
CREATE POLICY "Allow authenticated uploads" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'receipts');

-- Allow public read access
CREATE POLICY "Allow public read" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'receipts');
```

## Troubleshooting

### Migration Fails

- Check PostgreSQL version (Supabase uses PostgreSQL 15+)
- Ensure you have proper permissions
- Try running sections separately to identify the issue
- Check Supabase logs for detailed error messages

### RLS Policies Not Working

- Verify RLS is enabled: `ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;`
- Check policy conditions match your auth setup
- For anonymous users, ensure policies allow `auth.uid() IS NULL` or use different auth strategy

### Realtime Not Updating

- Verify replication is enabled in dashboard
- Check RLS policies allow SELECT (required for replication)
- Ensure Supabase client is properly initialized with realtime enabled

## Schema Overview

- **users**: User accounts (guest and premium)
- **trips**: Trip/group containers
- **trip_members**: Membership relationship (many-to-many)
- **expenses**: Individual expenses within trips
- **expense_splits**: How expenses are split among members
- **settlements**: Manual settlement entries

All tables have:
- UUID primary keys
- `created_at` timestamps
- RLS policies for security
- Indexes for performance


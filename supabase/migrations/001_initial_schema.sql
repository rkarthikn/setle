-- Setle Database Schema
-- Idempotent migration: can be run multiple times safely
-- ALWAYS UPDATE THIS FILE instead of creating new migrations
-- To apply: Run this entire script in Supabase SQL Editor

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- USERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies for users
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'users' AND policyname = 'users_select_policy'
  ) THEN
    CREATE POLICY users_select_policy ON users FOR SELECT USING (true);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'users' AND policyname = 'users_insert_policy'
  ) THEN
    CREATE POLICY users_insert_policy ON users FOR INSERT WITH CHECK (true);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'users' AND policyname = 'users_update_policy'
  ) THEN
    CREATE POLICY users_update_policy ON users FOR UPDATE USING (true) WITH CHECK (true);
  END IF;
END $$;

-- Enable RLS on users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- TRIPS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS trips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  cover_image TEXT,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies for trips
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'trips' AND policyname = 'trips_select_policy'
  ) THEN
    CREATE POLICY trips_select_policy ON trips FOR SELECT
      USING (
        EXISTS (
          SELECT 1 FROM trip_members
          WHERE trip_members.trip_id = trips.id
          AND trip_members.user_id = auth.uid()
        )
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'trips' AND policyname = 'trips_insert_policy'
  ) THEN
    CREATE POLICY trips_insert_policy ON trips FOR INSERT
      WITH CHECK (created_by = auth.uid() OR created_by IS NULL);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'trips' AND policyname = 'trips_update_policy'
  ) THEN
    CREATE POLICY trips_update_policy ON trips FOR UPDATE
      USING (
        EXISTS (
          SELECT 1 FROM trip_members
          WHERE trip_members.trip_id = trips.id
          AND trip_members.user_id = auth.uid()
          AND trip_members.role = 'admin'
        )
      );
  END IF;
END $$;

-- Enable RLS on trips
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- TRIP MEMBERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS trip_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(trip_id, user_id)
);

-- RLS Policies for trip_members
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'trip_members' AND policyname = 'trip_members_select_policy'
  ) THEN
    CREATE POLICY trip_members_select_policy ON trip_members FOR SELECT
      USING (
        EXISTS (
          SELECT 1 FROM trip_members tm
          WHERE tm.trip_id = trip_members.trip_id
          AND tm.user_id = auth.uid()
        )
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'trip_members' AND policyname = 'trip_members_insert_policy'
  ) THEN
    CREATE POLICY trip_members_insert_policy ON trip_members FOR INSERT
      WITH CHECK (user_id = auth.uid() OR user_id IS NULL);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'trip_members' AND policyname = 'trip_members_delete_policy'
  ) THEN
    CREATE POLICY trip_members_delete_policy ON trip_members FOR DELETE
      USING (
        user_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM trip_members tm
          WHERE tm.trip_id = trip_members.trip_id
          AND tm.user_id = auth.uid()
          AND tm.role = 'admin'
        )
      );
  END IF;
END $$;

-- Enable RLS on trip_members
ALTER TABLE trip_members ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- EXPENSES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  paid_by UUID REFERENCES users(id),
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  category TEXT,
  notes TEXT,
  receipt_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies for expenses
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'expenses' AND policyname = 'expenses_select_policy'
  ) THEN
    CREATE POLICY expenses_select_policy ON expenses FOR SELECT
      USING (
        EXISTS (
          SELECT 1 FROM trip_members
          WHERE trip_members.trip_id = expenses.trip_id
          AND trip_members.user_id = auth.uid()
        )
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'expenses' AND policyname = 'expenses_insert_policy'
  ) THEN
    CREATE POLICY expenses_insert_policy ON expenses FOR INSERT
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM trip_members
          WHERE trip_members.trip_id = expenses.trip_id
          AND trip_members.user_id = auth.uid()
        )
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'expenses' AND policyname = 'expenses_update_policy'
  ) THEN
    CREATE POLICY expenses_update_policy ON expenses FOR UPDATE
      USING (
        EXISTS (
          SELECT 1 FROM trip_members
          WHERE trip_members.trip_id = expenses.trip_id
          AND trip_members.user_id = auth.uid()
        )
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'expenses' AND policyname = 'expenses_delete_policy'
  ) THEN
    CREATE POLICY expenses_delete_policy ON expenses FOR DELETE
      USING (
        EXISTS (
          SELECT 1 FROM trip_members
          WHERE trip_members.trip_id = expenses.trip_id
          AND trip_members.user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Enable RLS on expenses
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- EXPENSE SPLITS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS expense_splits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  expense_id UUID NOT NULL REFERENCES expenses(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  share_amount DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(expense_id, user_id)
);

-- RLS Policies for expense_splits
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'expense_splits' AND policyname = 'expense_splits_select_policy'
  ) THEN
    CREATE POLICY expense_splits_select_policy ON expense_splits FOR SELECT
      USING (
        EXISTS (
          SELECT 1 FROM expenses e
          JOIN trip_members tm ON tm.trip_id = e.trip_id
          WHERE e.id = expense_splits.expense_id
          AND tm.user_id = auth.uid()
        )
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'expense_splits' AND policyname = 'expense_splits_insert_policy'
  ) THEN
    CREATE POLICY expense_splits_insert_policy ON expense_splits FOR INSERT
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM expenses e
          JOIN trip_members tm ON tm.trip_id = e.trip_id
          WHERE e.id = expense_splits.expense_id
          AND tm.user_id = auth.uid()
        )
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'expense_splits' AND policyname = 'expense_splits_update_policy'
  ) THEN
    CREATE POLICY expense_splits_update_policy ON expense_splits FOR UPDATE
      USING (
        EXISTS (
          SELECT 1 FROM expenses e
          JOIN trip_members tm ON tm.trip_id = e.trip_id
          WHERE e.id = expense_splits.expense_id
          AND tm.user_id = auth.uid()
        )
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'expense_splits' AND policyname = 'expense_splits_delete_policy'
  ) THEN
    CREATE POLICY expense_splits_delete_policy ON expense_splits FOR DELETE
      USING (
        EXISTS (
          SELECT 1 FROM expenses e
          JOIN trip_members tm ON tm.trip_id = e.trip_id
          WHERE e.id = expense_splits.expense_id
          AND tm.user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Enable RLS on expense_splits
ALTER TABLE expense_splits ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- SETTLEMENTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS settlements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  from_user UUID NOT NULL REFERENCES users(id),
  to_user UUID NOT NULL REFERENCES users(id),
  amount DECIMAL(10, 2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  method TEXT NOT NULL DEFAULT 'manual' CHECK (method IN ('manual', 'upi-placeholder')),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (from_user != to_user)
);

-- RLS Policies for settlements
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'settlements' AND policyname = 'settlements_select_policy'
  ) THEN
    CREATE POLICY settlements_select_policy ON settlements FOR SELECT
      USING (
        EXISTS (
          SELECT 1 FROM trip_members
          WHERE trip_members.trip_id = settlements.trip_id
          AND trip_members.user_id = auth.uid()
        )
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'settlements' AND policyname = 'settlements_insert_policy'
  ) THEN
    CREATE POLICY settlements_insert_policy ON settlements FOR INSERT
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM trip_members
          WHERE trip_members.trip_id = settlements.trip_id
          AND trip_members.user_id = auth.uid()
        )
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'settlements' AND policyname = 'settlements_update_policy'
  ) THEN
    CREATE POLICY settlements_update_policy ON settlements FOR UPDATE
      USING (
        EXISTS (
          SELECT 1 FROM trip_members
          WHERE trip_members.trip_id = settlements.trip_id
          AND trip_members.user_id = auth.uid()
        )
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'settlements' AND policyname = 'settlements_delete_policy'
  ) THEN
    CREATE POLICY settlements_delete_policy ON settlements FOR DELETE
      USING (
        EXISTS (
          SELECT 1 FROM trip_members
          WHERE trip_members.trip_id = settlements.trip_id
          AND trip_members.user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Enable RLS on settlements
ALTER TABLE settlements ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Trip members indexes
CREATE INDEX IF NOT EXISTS idx_trip_members_trip_id ON trip_members(trip_id);
CREATE INDEX IF NOT EXISTS idx_trip_members_user_id ON trip_members(user_id);

-- Expenses indexes
CREATE INDEX IF NOT EXISTS idx_expenses_trip_id ON expenses(trip_id);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date);
CREATE INDEX IF NOT EXISTS idx_expenses_paid_by ON expenses(paid_by);

-- Expense splits indexes
CREATE INDEX IF NOT EXISTS idx_expense_splits_expense_id ON expense_splits(expense_id);
CREATE INDEX IF NOT EXISTS idx_expense_splits_user_id ON expense_splits(user_id);

-- Settlements indexes
CREATE INDEX IF NOT EXISTS idx_settlements_trip_id ON settlements(trip_id);
CREATE INDEX IF NOT EXISTS idx_settlements_from_user ON settlements(from_user);
CREATE INDEX IF NOT EXISTS idx_settlements_to_user ON settlements(to_user);

-- ============================================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_trips_updated_at ON trips;
CREATE TRIGGER update_trips_updated_at
    BEFORE UPDATE ON trips
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_expenses_updated_at ON expenses;
CREATE TRIGGER update_expenses_updated_at
    BEFORE UPDATE ON expenses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- NOTES
-- ============================================================================
-- Realtime subscriptions should be enabled via Supabase Dashboard:
-- 1. Go to Database → Replication
-- 2. Enable replication for: trips, trip_members, expenses, expense_splits, settlements
--
-- Storage bucket setup:
-- 1. Go to Storage → Create bucket named 'receipts'
-- 2. Set as public
-- 3. Configure policies for authenticated/anonymous users


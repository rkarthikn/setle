# Setle

A modern, intuitive group expense app designed for trips, events, and shared activities. Setle improves on existing solutions with real-time collaboration, offline-first reliability, a Liquid Glass UI, and future-ready premium features.

## Features

- **Guest-first onboarding** - No login required to get started
- **Realtime sync** - Parallel editing with live updates
- **Offline-first** - Local database with sync queue for reliability
- **Liquid Glass UI** - Beautiful iOS 26 design with soft blur and translucency
- **Privacy-focused** - No unnecessary data collection
- **Simple yet powerful** - Perfect for casual trips and long tours

## Tech Stack

- **Platform**: iOS 26.0+ (SwiftUI)
- **Backend**: Supabase (PostgreSQL + Realtime + Auth + Storage)
- **Local Storage**: GRDB (SQLite)
- **Architecture**: MVVM with Combine/async-await
- **UI**: Liquid Glass design system

## Project Structure

```
setle/
├── Models/              # Data models
├── Services/           # Core services (Supabase, Local DB, Sync)
├── ViewModels/         # Business logic
├── Views/              # SwiftUI views
│   ├── Onboarding/
│   ├── Trips/
│   ├── Expenses/
│   └── Settlements/
├── Components/        # Reusable UI components
│   └── LiquidGlass/
└── Utilities/          # Helper utilities

supabase/
└── migrations/         # Database migrations (idempotent)
```

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd setle
   ```

2. **Set up Supabase**
   - Create a new Supabase project
   - Apply the migration from `supabase/migrations/001_initial_schema.sql`
   - See `SETUP.md` for detailed instructions

3. **Configure environment variables**
   - Copy `.env.example` to `.env` (not committed)
   - Add your Supabase URL and anon key

4. **Open in Xcode**
   ```bash
   open setle.xcodeproj
   ```

5. **Build and run**
   - Dependencies will be resolved via Swift Package Manager
   - Run on iOS 26.0+ simulator or device

## Development

### Migration Strategy

- **Single migration file**: Always update `supabase/migrations/001_initial_schema.sql`
- **Idempotent**: Safe to run multiple times
- **No incremental migrations**: Update the original file and reapply

### Configuration

All environment variables are centralized in `setle/Services/Config.swift`. Never hardcode values or access environment variables directly.

## License

[Add your license here]

## Roadmap

- [x] Phase 0: Prerequisites & Setup
- [ ] Phase 1: Foundation (Data Models, Services)
- [ ] Phase 2: Core Features (Trips, Expenses, Settlements)
- [ ] Phase 3: UI & Polish (Liquid Glass)
- [ ] Phase 4: Advanced Features (Offline + Realtime)
- [ ] Phase 5: Final Polish & Testing


//
//  Config.swift
//  setle
//
//  Centralized configuration singleton for all environment variables
//  Single source of truth - all services read from here
//

import Foundation

/// Centralized configuration manager
/// All environment variables are loaded here and accessed via Config.shared
class Config {
    static let shared = Config()
    
    // MARK: - Supabase Configuration
    
    /// Supabase project URL
    /// Set via environment variable: SUPABASE_URL
    let supabaseURL: String
    
    /// Supabase anonymous/public key
    /// Set via environment variable: SUPABASE_ANON_KEY
    let supabaseAnonKey: String
    
    // MARK: - Storage Configuration
    
    /// Storage bucket name for receipts
    /// Set via environment variable: STORAGE_BUCKET (defaults to 'receipts')
    let storageBucket: String
    
    // MARK: - App Configuration
    
    /// App version
    /// Set via environment variable: APP_VERSION (defaults to '1.0.0')
    let appVersion: String
    
    /// Maximum trips allowed in free tier
    /// Set via environment variable: MAX_TRIPS_FREE (defaults to 3)
    let maxTripsFree: Int
    
    // MARK: - Feature Flags
    
    /// Enable realtime subscriptions
    /// Set via environment variable: ENABLE_REALTIME (defaults to true)
    let enableRealtime: Bool
    
    /// Enable offline sync
    /// Set via environment variable: ENABLE_OFFLINE_SYNC (defaults to true)
    let enableOfflineSync: Bool
    
    // MARK: - Initialization
    
    private init() {
        // Load all environment variables from ProcessInfo
        let env = ProcessInfo.processInfo.environment
        
        // Supabase configuration
        supabaseURL = env["SUPABASE_URL"] ?? ""
        supabaseAnonKey = env["SUPABASE_ANON_KEY"] ?? ""
        
        // Storage configuration
        storageBucket = env["STORAGE_BUCKET"] ?? "receipts"
        
        // App configuration
        appVersion = env["APP_VERSION"] ?? "1.0.0"
        maxTripsFree = Int(env["MAX_TRIPS_FREE"] ?? "3") ?? 3
        
        // Feature flags
        enableRealtime = env["ENABLE_REALTIME"]?.lowercased() != "false"
        enableOfflineSync = env["ENABLE_OFFLINE_SYNC"]?.lowercased() != "false"
        
        // Validate required configuration
        validateConfiguration()
    }
    
    // MARK: - Validation
    
    private func validateConfiguration() {
        #if DEBUG
        if supabaseURL.isEmpty {
            print("⚠️ WARNING: SUPABASE_URL is not set. Set it in Xcode scheme environment variables.")
        }
        if supabaseAnonKey.isEmpty {
            print("⚠️ WARNING: SUPABASE_ANON_KEY is not set. Set it in Xcode scheme environment variables.")
        }
        #endif
    }
    
    // MARK: - Computed Properties
    
    /// Check if Supabase is properly configured
    var isSupabaseConfigured: Bool {
        !supabaseURL.isEmpty && !supabaseAnonKey.isEmpty
    }
}


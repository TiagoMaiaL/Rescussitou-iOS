//
//  UserDefaults+Constants.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 14/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

extension UserDefaults {

    // MARK: Constants

    /// The keys of the specific values saved by the app.
    enum Keys {
        static let WereSongsSeeded = "were_songs_seeded"
        static let WasAppFirstLaunched = "was_launched"
        static let SongsVersion = "songs_version"
    }

    // MARK: Properties

    /// A flag indicating whether the songs were added into core data or not.
    static var wereSongsSeeded: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.WereSongsSeeded)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.WereSongsSeeded)
        }
    }

    /// A flag indicating if this is the first launch of the app.
    static var isFirstLaunch: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: Keys.WasAppFirstLaunched)
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: Keys.WasAppFirstLaunched)
        }
    }

    /// The current version of the songs stored by the app.
    static var currentSongsVersion: Int? {
        let version = UserDefaults.standard.integer(forKey: Keys.SongsVersion)
        return version > 0 ? version : nil
    }
}

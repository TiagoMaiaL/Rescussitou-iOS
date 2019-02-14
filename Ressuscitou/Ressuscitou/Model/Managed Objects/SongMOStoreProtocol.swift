//
//  SongMOStoreProtocol.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 14/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// The store in charge of creating, fetching and deleting SongMOs.
protocol SongMOStoreProtocol {

    // MARK: Imperatives

    /// Persists the received songs into core data.
    /// - Parameters:
    ///     - songs: the songs to be persisted.
    ///     - context: the managed object context in which the new managed objects will be added.
    /// - Returns: an array with the added song managed objects.
    func createSongsManagedObjects(fromJSONSongs songs: [Song],
                                   usingContext context: NSManagedObjectContext) -> [SongMO]
}

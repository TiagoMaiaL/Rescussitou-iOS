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

    /// Makes a fetched results controller configured to get all songs from A to Z.
    /// - Returns: the configured fetched results controller for all songs.
    func makeFetchedResultsControllerForAllSongs(
        usingContext context: NSManagedObjectContext
        ) -> NSFetchedResultsController<SongMO>

    /// Makes a fetched results controller for the passed song stage category.
    /// - Returns: the configured fetched results controller for the specific stage category.
    func makeFetchedResultsControllerForStageCategory(
        _ stage: SongMO.StageCategory,
        usingContext context: NSManagedObjectContext
        ) -> NSFetchedResultsController<SongMO>

    /// Makes a fetched results controller for the passed song liturgical time.
    /// - Returns: the configured fetched results controller for the specific liturgical time.
    func makeFetchedResultsControllerForLiturgicalTimeCategory(
        _ liturgicalTime: SongMO.LiturgicalTimeCategory,
        usingContext context: NSManagedObjectContext
        ) -> NSFetchedResultsController<SongMO>

    /// Persists the received songs into core data.
    /// - Parameters:
    ///     - songs: the songs to be persisted.
    ///     - context: the managed object context in which the new managed objects will be added.
    /// - Returns: an array with the added song managed objects.
    func createSongsManagedObjects(fromJSONSongs songs: [Song],
                                   usingContext context: NSManagedObjectContext) -> [SongMO]
}

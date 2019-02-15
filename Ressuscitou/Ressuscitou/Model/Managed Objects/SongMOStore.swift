//
//  SongMOStore.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 14/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

struct SongsMOStore: SongMOStoreProtocol {

    // MARK: Imperatives

    func makeFetchedResultsControllerForAllSongs(
        usingContext context: NSManagedObjectContext
        ) -> NSFetchedResultsController<SongMO> {

        let request: NSFetchRequest<SongMO> = SongMO.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: "all")
        return frc
    }

    func createSongsManagedObjects(fromJSONSongs songs: [Song],
                                   usingContext context: NSManagedObjectContext) -> [SongMO] {
        return songs.map { createSongManagedObject(fromJSONSong: $0, usingContext: context) }
    }

    /// Creates a song managed object from the passed song struct.
    /// - Parameters:
    ///     - song: the song struct to be persisted.
    ///     - context: the managed object context in which the new managed object will be added.
    /// - Returns: the added song managed object.
    private func createSongManagedObject(fromJSONSong song: Song,
                                         usingContext context: NSManagedObjectContext) -> SongMO {
        let songManagedObject = SongMO(context: context)

        songManagedObject.title = song.title
        songManagedObject.category = Int16(song.category)
        if let number = Int16(song.number) {
            songManagedObject.number = number
        }
        songManagedObject.base64HTML = song.base64Html

        songManagedObject.isForFinal = song.isForFinal
        songManagedObject.isForAdvent = song.isForAdvent
        songManagedObject.isForBreadFraction = song.isForBreadFraction
        songManagedObject.isForChildren = song.isForChildren
        songManagedObject.isForChristmas = song.isForChristmas
        songManagedObject.isForCommunion = song.isForCommunion
        songManagedObject.isForEaster = song.isForEaster
        songManagedObject.isForEntrance = song.isForEntrance
        songManagedObject.isForLaudsOrEve = song.isForLaudsOrEve
        songManagedObject.isForLent = song.isForLent
        songManagedObject.isForPeace = song.isForPeace
        songManagedObject.isForPentecost = song.isForPentecost
        songManagedObject.isForVirginMary = song.isForVirginMary

        return songManagedObject
    }
}

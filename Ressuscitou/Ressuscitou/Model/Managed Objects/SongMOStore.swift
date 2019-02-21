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
        return makeFetchedResultsController(filterPredicate: nil, context: context)
    }

    func makeFetchedResultsControllerForStageCategory(
        _ stage: SongMO.StageCategory,
        usingContext context: NSManagedObjectContext
        ) -> NSFetchedResultsController<SongMO> {
        return makeFetchedResultsController(
            filterPredicate: NSPredicate(format: "category = %d", stage.rawValue + 1),
            context: context
        )
    }

    func makeFetchedResultsControllerForLiturgicalTimeCategory(
        _ liturgicalTime: SongMO.LiturgicalTimeCategory,
        usingContext context: NSManagedObjectContext
        ) -> NSFetchedResultsController<SongMO> {
        var text: String!

        switch liturgicalTime {
        case .advent:
            text = "isForAdvent = %d"
        case .christmas:
            text = "isForChristmas = %d"
        case .lent:
            text = "isForLent = %d"
        case .easter:
            text = "isForEaster = %d"
        case .pentecost:
            text = "isForPentecost = %d"
        }

        return makeFetchedResultsController(
            filterPredicate: NSPredicate(format: text, true),
            context: context
        )
    }

    func makeFetchedResultsControllerForEucaristCategory(
        _ eucaristPart: SongMO.EucaristCategory,
        usingContext context: NSManagedObjectContext
        ) -> NSFetchedResultsController<SongMO> {
        var text: String!

        switch eucaristPart {
        case .entrance:
            text = "isForEntrance = %d"
        case .peace:
            text = "isForPeace = %d"
        case .breadFraction:
            text = "isForBreadFraction = %d"
        case .communion:
            text = "isForCommunion = %d"
        case .final:
            text = "isForFinal = %d"
        }

        return makeFetchedResultsController(
            filterPredicate: NSPredicate(format: text, true),
            context: context
        )
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

        songManagedObject.title = song.title.capitalizingFirstLetterOnly()
        songManagedObject.content = song.content
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

    /// Makes a fetched results controller using the filter predicate.
    /// - Parameters:
    ///     - predicate: the filter predicate associated to the fetch request.
    ///     - context: the context to be used for the fetch.
    /// - Returns: the configured fetched results controller.
    private func makeFetchedResultsController(filterPredicate: NSPredicate?,
                                              context: NSManagedObjectContext) -> NSFetchedResultsController<SongMO> {
        let request: NSFetchRequest<SongMO> = SongMO.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        request.predicate = filterPredicate

        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: "all")
        return frc
    }
}

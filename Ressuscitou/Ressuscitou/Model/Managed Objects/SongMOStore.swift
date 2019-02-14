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

    func createSongsManagedObjects(fromJSONSongs songs: Songs,
                                   usingContext context: NSManagedObjectContext) -> [SongMO] {
        // TODO: Implement routing to create and save the managed objects.
        return []
    }
}

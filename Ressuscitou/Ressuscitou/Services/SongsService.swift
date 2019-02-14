//
//  SongsService.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 14/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

class SongsService: SongsServiceProtocol {

    // MARK: Properties

    var dataController: DataControllerProtocol
    var songsStore: SongMOStoreProtocol

    // MARK: Initializers

    required init(dataController: DataControllerProtocol, songsStore: SongMOStoreProtocol) {
        self.dataController = dataController
        self.songsStore = songsStore
    }

    // MARK: Imperatives

    func handleSongsJson(_ jsonData: Data, withCompletionHandler handler: @escaping (Error?) -> Void) {
        // Turn the data into the temporary songs structs, then persist them using the store.
        let decoder = JSONDecoder()

        do {
            let songs = try decoder.decode([Song].self, from: jsonData)
            self.dataController.dataContainer.performBackgroundTask { context in
                _ = self.songsStore.createSongsManagedObjects(fromJSONSongs: songs, usingContext: context)
                do {
                    try context.save()
                    handler(nil)
                } catch {
                    print("Error while saving context.")
                    handler(error)
                }
            }
        } catch {
            print("Error while decoding json.")
            handler(error)
        }
    }
}

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

    func handleSongsJson(_ jsonData: Data, withCompletionHandler: (Error?) -> Void) {
        // Turn the data into the temporary representation songs struct, then persist them.
        let decoder = JSONDecoder()

        do {
            let songs = try decoder.decode([Song].self, from: jsonData)
            self.dataController.dataContainer.performBackgroundTask { context in
                let mos = self.songsStore.createSongsManagedObjects(fromJSONSongs: songs, usingContext: context)
                print(mos)
            }
        } catch {
            // Call handler with an error.
            print("error")
        }
    }
}

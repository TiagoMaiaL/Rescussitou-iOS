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

    private(set) var dataController: DataControllerProtocol
    private(set) var songsStore: SongMOStoreProtocol
    private(set) var apiClient: APIClientProtocol

    // MARK: Initializers

    required init(
        dataController: DataControllerProtocol,
        songsStore: SongMOStoreProtocol,
        apiClient: APIClientProtocol
        ) {
        self.dataController = dataController
        self.songsStore = songsStore
        self.apiClient = apiClient
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

    func downloadSound(fromSong song: SongMO, withCompletionHandler: @escaping (Bool, Error?) -> Void) {
        // TODO: Download the song.
    }
}

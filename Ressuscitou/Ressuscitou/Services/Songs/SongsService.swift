//
//  SongsService.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 14/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import UIKit

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

    func requestSongsVersion(withCompletionHandler completionHandler: @escaping (Int?, Error?) -> Void) {
        guard let versionUrl = getBaseUrl().appendingPathComponent("cantos_versao.txt").appendingQuery("raw=true") else {
            preconditionFailure("The URL for the songs version file must be set.")
        }
        let getTask = apiClient.makeConfiguredGETTask(forResourceAtUrl: versionUrl) { data, error in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }

            guard error == nil, let data = data else {
                completionHandler(nil, error!)
                return
            }

            guard let versionText = String(data: data, encoding: .utf8), let version = Int(versionText) else {
                completionHandler(nil, URLSessionTask.TaskError.unexpectedDataContent)
                return
            }

            completionHandler(version, nil)
        }
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        getTask.resume()
    }

    func downloadAudio(
        fromSong song: SongMO,
        withCompletionHandler handler: @escaping (Bool, SongsServiceError?) -> Void
        ) -> URLSessionDownloadTask? {
        guard let songContext = song.managedObjectContext else {
            preconditionFailure("Songs must have a managed object context.")
        }
        guard song.hasAudio, var songTitle = song.title?.uppercased() else { return nil }
        // TODO: Write a test to make sure this name formatting is right.
        songTitle = songTitle.folding(
            options: .diacriticInsensitive,
            locale: nil
        ).components(separatedBy: .punctuationCharacters).joined()

        guard let audioUrl = getBaseUrl()
            .appendingPathComponent("audios/\(songTitle).mp3")
            .appendingQuery("raw=true") else {
                preconditionFailure("The url for audios must be set.")
        }

        let downloadTask = apiClient.makeConfiguredDownloadTask(forResourceAtUrl: audioUrl) { resourceUrl, taskError in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }

            guard taskError == nil else {
                var error: SongsServiceError!

                switch taskError! {
                case .connection:
                    error = .internetConnection
                case .serverResponse(let statusCode):
                    if let statusCode = statusCode, statusCode >= 500 {
                        error = .serverNotAvailable
                    } else {
                        error = .resourceNotAvailable
                    }
                case .unexpectedDataContent:
                    error = .resourceNotAvailable
                }

                handler(false, error)
                return
            }

            guard let resourceUrl = resourceUrl else {
                handler(false, .readResource)
                return
            }

            do {
                let audioData = try Data(contentsOf: resourceUrl)

                songContext.perform {
                    song.audio = audioData

                    do {
                        try songContext.save()
                        handler(true, nil)
                    } catch {
                        songContext.rollback()
                        handler(false, .readResource)
                    }
                }
            } catch {
                handler(false, .readResource)
            }
        }
        downloadTask.resume()
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }

        return downloadTask
    }
}

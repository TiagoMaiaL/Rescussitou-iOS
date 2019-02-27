//
//  SongsServiceProtocol.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 14/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// The service in charge of handling songs requests, parsing and persistence using a store.
protocol SongsServiceProtocol {

    // MARK: Properties

    /// The data controller used to persist the parsed json songs.
    var dataController: DataControllerProtocol { get }

    /// The store used to persist the songs parsed from the json data.
    var songsStore: SongMOStoreProtocol { get }

    /// The client used to download the sounds and also update the songs.
    var apiClient: APIClientProtocol { get }

    // MARK: Initializers

    init(dataController: DataControllerProtocol, songsStore: SongMOStoreProtocol, apiClient: APIClientProtocol)

    // MARK: Imperatives

    /// Handles the passed songs json data and persists it using the store.
    /// - Parameters:
    ///     - jsonData: the json data to be handled.
    ///     - completionHandler: the completion handler called when finished parsing and storing the songs.
    func handleSongsJson(_ jsonData: Data, withCompletionHandler handler: @escaping (Error?) -> Void)

    /// Downloads the sound related to the passed song entity and persists it using core data.
    /// - Parameters:
    ///     - song: the song related to the sound to be downloaded.
    ///     - completionHandler: the completion handler called after the download completes, or if an error occurs.
    func downloadSound(
        fromSong song: SongMO,
        withCompletionHandler handler: @escaping (Bool, SongsServiceError?) -> Void
    )
}

/// The possible errors related to the songs service operations.
enum SongsServiceError: Error {
    case internetConnection
    case serverNotAvailable
    case resourceNotAvailable
    case readResource
}

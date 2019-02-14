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

    // MARK: Initializers

    init(dataController: DataControllerProtocol, songsStore: SongMOStoreProtocol)

    // MARK: Imperatives

    /// Handles the passed songs json data and persists it using the store.
    /// - Parameters:
    ///     - jsonData: the json data to be handled.
    ///     - completionHandler: the completion handler called when finished parsing and storing the songs.
    func handleSongsJson(_ jsonData: Data, withCompletionHandler handler: @escaping (Error?) -> Void)
}

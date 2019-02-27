//
//  APIClient.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 26/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// The client used to make the configured tasks from the passed url session.
struct APIClient: APIClientProtocol {

    // MARK: Properties

    var session: URLSession

    // MARK: Initializers

    init(session: URLSession) {
        self.session = session
    }

    // MARK: Imperatives

    /// Makes a configured download task for the specified resource.
    /// - Parameters:
    ///     - url: the url of the file to be downloaded.
    ///     - handler: the handler called when the task finishes.
    /// - Returns: the configure download task.
    func makeConfiguredDownloadTask(
        forResourceAtUrl url: URL,
        withCompletionHandler handler: @escaping (URL?, Error?) -> Void
        ) -> URLSessionDownloadTask {
        return session.downloadTask(with: url, completionHandler: { fileURL, response, error in
            // TODO: Make the treatment of any errors, and call the handler with the results.
        })
    }
}

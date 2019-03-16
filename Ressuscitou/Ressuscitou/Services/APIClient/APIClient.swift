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

    func makeConfiguredGETTask(
        forResourceAtUrl url: URL,
        withCompletionHandler handler: @escaping (Data?, URLSessionTask.TaskError?) -> Void
        ) -> URLSessionDataTask {
        return session.dataTask(with: url) { data, response, error in
            guard error == nil, data != nil else {
                handler(nil, .connection)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                handler(nil, .connection)
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                handler(nil, .serverResponse(statusCode: httpResponse.statusCode))
                return
            }

            handler(data!, nil)
        }
    }

    func makeConfiguredDownloadTask(
        forResourceAtUrl url: URL,
        withCompletionHandler handler: @escaping (URL?, URLSessionTask.TaskError?) -> Void
        ) -> URLSessionDownloadTask {
        return session.downloadTask(with: url, completionHandler: { fileURL, response, error in
            guard error == nil, fileURL != nil else {
                handler(nil, .connection)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                handler(nil, .connection)
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                handler(nil, .serverResponse(statusCode: httpResponse.statusCode))
                return
            }

            handler(url, nil)
        })
    }
}

//
//  APIClientProtocol.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 26/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// The client used to make the configured tasks from the passed url session.
protocol APIClientProtocol {

    // MARK: Properties

    /// The URLSession used to create the tasks.
    var session: URLSession { get }

    // MARK: Initializers

    init(session: URLSession)

    // MARK: Imperatives

    /// Makes a configured download task for the specified resource.
    /// - Parameters:
    ///     - url: the url of the file to be downloaded.
    ///     - handler: the handler called when the task finishes.
    /// - Returns: the configure download task.
    func makeConfiguredDownloadTask(
        forResourceAtUrl url: URL,
        withCompletionHandler handler: @escaping (URL?, URLSessionTask.TaskError?) -> Void
        ) -> URLSessionDownloadTask
}

extension URLSessionTask {

    // MARK: Error type

    enum TaskError: Error {
        case connection
        case serverResponse(statusCode: Int?)
    }
}

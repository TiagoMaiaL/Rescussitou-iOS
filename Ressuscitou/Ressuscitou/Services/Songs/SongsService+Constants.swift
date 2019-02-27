//
//  SongsService+Constants.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 27/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

extension SongsService {

    // MARK: Constants

    /// API releated constants to create the urls.
    enum API {
        static let Scheme = "https"
        static let Host = "github.com"
        static let Path = "/otaviogrrd/Ressuscitou_Android/blob/master/"
    }

    // MARK: Imperatives

    /// Creates a url based on the API constants.
    func getBaseUrl() -> URL {
        var components = URLComponents()
        components.scheme = API.Scheme
        components.host = API.Host
        components.path = API.Path

        guard let url = components.url else {
            preconditionFailure("The base URL must be set.")
        }
        return url
    }
}

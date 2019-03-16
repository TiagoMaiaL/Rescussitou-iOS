//
//  URL+Helpers.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 15/03/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

extension URL {
    /// Appends the provided query part of the URL and returns the configured URL.
    func appendingQuery(_ query: String) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
        components.query = query

        return components.url
    }
}

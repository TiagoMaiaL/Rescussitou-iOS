//
//  String+Helpers.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 19/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

extension String {
    /// - Returns: the string with the first letter uppercased and the rest of the string in lowercase.
    func capitalizingFirstLetterOnly() -> String {
        return prefix(1).uppercased() + dropFirst().lowercased()
    }
}

//
//  SongMO.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// The song entity.
class SongMO: NSManagedObject {

    // MARK: Types

    /// The stage category of each song.
    enum StageCategory: Int, CaseIterable {
        case preCathecumenate = 0
        case liturgicalSongs
        case cathecumenate
        case election

        /// The title associated with each category.
        var title: String {
            switch self {
            case .preCathecumenate:
                return "Pré-catecumenato"
            case .liturgicalSongs:
                return "Cantos litúrgicos"
            case .cathecumenate:
                return "Catecumenato"
            case .election:
                return "Eleição"
            }
        }
    }

    /// The liturgical time of each song.
    enum LiturgicalTimeCategory: Int, CaseIterable {
        case advent = 0
        case christmas
        case lent
        case easter
        case pentecost

        /// The title associated with each category.
        var title: String {
            switch self {
            case .advent:
                return "Advento"
            case .christmas:
                return "Natal"
            case .lent:
                return "Quaresma"
            case .easter:
                return "Páscoa"
            case .pentecost:
                return "Pentecostes"
            }
        }
    }
}

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
                return NSLocalizedString("Pré-catecumenato", comment: "One of the stage categories.")
            case .liturgicalSongs:
                return NSLocalizedString("Cantos litúrgicos", comment: "One of the stage categories.")
            case .cathecumenate:
                return NSLocalizedString("Catecumenato", comment: "One of the stage categories.")
            case .election:
                return NSLocalizedString("Eleição", comment: "One of the stage categories.")
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
                return NSLocalizedString("Advento", comment: "One of the liturgical time categories.")
            case .christmas:
                return NSLocalizedString("Natal", comment: "One of the liturgical time categories.")
            case .lent:
                return NSLocalizedString("Quaresma", comment: "One of the liturgical time categories.")
            case .easter:
                return NSLocalizedString("Páscoa", comment: "One of the liturgical time categories.")
            case .pentecost:
                return NSLocalizedString("Pentecostes", comment: "One of the liturgical time categories.")
            }
        }
    }

    enum EucaristCategory: Int, CaseIterable {
        case entrance = 0
        case peace
        case breadFraction
        case communion
        case final

        /// The title associated with each category.
        var title: String {
            switch self {
            case .entrance:
                return NSLocalizedString("Cantos de entrada", comment: "One of the eucarist categories.")
            case .peace:
                return NSLocalizedString("Paz", comment: "One of the eucarist categories.")
            case .breadFraction:
                return NSLocalizedString("Fração do pão", comment: "One of the eucarist categories.")
            case .communion:
                return NSLocalizedString("Comunhão", comment: "One of the eucarist categories.")
            case .final:
                return NSLocalizedString("Canto final", comment: "One of the eucarist categories.")
            }
        }
    }

    // MARK: Properties

    /// The category of the song.
    var stageCategory: StageCategory? {
        return StageCategory(rawValue: (Int(category) - 1))
    }
}

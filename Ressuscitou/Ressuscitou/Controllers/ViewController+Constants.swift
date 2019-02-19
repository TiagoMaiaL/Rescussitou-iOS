//
//  ViewController+Constants.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

extension UIViewController {

    /// The segue identifiers used throughout the code.
    enum SegueIdentifiers {
        static let InitialControllerSegue = "Show initial controller"
        static let MenuControllerSegue = "Show menu"
        static let SongControllerSegue = "Show song"
    }

    /// The theme colors used in the application.
    enum Colors {
        static let BaseRed = UIColor(red: 241/255, green: 0, blue: 17/255, alpha: 1)
    }

    /// The user info keys used in the controllers observing notification events.
    enum UserInfoKeys {
        static let Filter = "filter"
        static let SelectedCategory = "selected category"
    }
}


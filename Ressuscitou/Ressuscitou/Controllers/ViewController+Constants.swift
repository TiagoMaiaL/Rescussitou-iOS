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
        static let initialControllerSegue = "Show initial controller"
        static let menuControllerSegue = "Show menu"
        static let songControllerSegue = "Show song"
    }

    enum Colors {
        static let baseRed = UIColor(red: 241/255, green: 0, blue: 17/255, alpha: 1)
    }
}


//
//  SplashViewController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// The view controller in charge of initializing the core data stack and also seed the database.
class SplashViewController: UIViewController {

    // MARK: Life cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.performSegue(withIdentifier: SegueIdentifiers.initialControllerSegue, sender: self)
        }
    }

}

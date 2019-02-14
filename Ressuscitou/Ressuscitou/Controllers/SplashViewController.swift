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

    // MARK: Properties

    /// The data controller in charge of managing the core data stack.
    var dataController: DataControllerProtocol!

    // MARK: Life cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        precondition(dataController != nil)

        dataController.load { description, error in
            guard error == nil else {
                // TODO: Display error to user.
                print("Error")
                return
            }

            DispatchQueue.main.async {
                self.performSegue(withIdentifier: SegueIdentifiers.initialControllerSegue, sender: self)
            }
        }
    }
}

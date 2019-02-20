//
//  WarningViewController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 19/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// View controller presenting the app usage warning.
class WarningViewController: UIViewController {

    // MARK: Properties

    /// The closure to be called with the porpuse of configuring the songs controller for display.
    /// - Note: the configuration involves injecting any dependencies the songs controller needs.
    var songsControllerPreparationHandler: ((SongsTableViewController) -> Void)!

    /// The alpha transitioning delegate used to present the songs controller.
    private let alphaTransitioningDelegate = AlphaTransitioningDelegate()

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(songsControllerPreparationHandler != nil)
    }

    // MARK: Actions

    @IBAction func dismissWarning(_ sender: UIButton) {
        //            UserDefaults.isFirstLaunch = false
        performSegue(withIdentifier: SegueIdentifiers.SongsControllerSegue, sender: self)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = alphaTransitioningDelegate

        if segue.identifier == SegueIdentifiers.SongsControllerSegue,
            let navigationController = segue.destination as? UINavigationController,
            let songsController = navigationController.viewControllers.first as? SongsTableViewController {
            // Configure the songs controller by using the handler.
            songsControllerPreparationHandler(songsController)
        }
    }
}

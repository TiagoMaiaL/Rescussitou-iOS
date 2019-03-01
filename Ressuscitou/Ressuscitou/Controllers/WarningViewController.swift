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
    var songsControllerPreparationHandler: ((SongsListingViewController) -> Void)!

    /// The alpha transitioning delegate used to present the songs controller.
    private let alphaTransitioningDelegate = AlphaTransitioningDelegate(transitionDuration: 0.3)

    /// The stack view holding the sub views of the controller.
    @IBOutlet weak var mainStackView: UIStackView!

    /// The stack view containing the labels of the warning.
    @IBOutlet weak var informationStackView: UIStackView!

    /// The image view displaying the guitar image.
    @IBOutlet weak var guitarImageView: UIImageView!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(songsControllerPreparationHandler != nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Perform appearance animations.
        UIView.animate(withDuration: 0.1) {
             self.informationStackView.alpha = 1
        }
        UIView.animate(withDuration: 0.2) {
            self.mainStackView.spacing = 10
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Perform dismissal animations.
        UIView.animate(withDuration: 0.2) {
            self.guitarImageView.frame.origin.x -= 20
        }
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
            let songsController = navigationController.viewControllers.first as? SongsListingViewController {
            // Configure the songs controller by using the handler.
            songsControllerPreparationHandler(songsController)
        }
    }
}

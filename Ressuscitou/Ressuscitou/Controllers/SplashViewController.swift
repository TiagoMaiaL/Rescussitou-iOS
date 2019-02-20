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

    /// The songs service in charge of parsing and persisting the bundle songs json file.
    var songsService: SongsServiceProtocol!

    /// The transitioning delegate used to present other view controllers.
    private let alphaTransitioningDelegate = AlphaTransitioningDelegate(transitionDuration: 0.5)

    /// The label displaying the app's name.
    @IBOutlet weak var appTitleLabel: UILabel!

    /// The vertical constraint of the title label.
    @IBOutlet weak var titleVerticalConstraint: NSLayoutConstraint!

    // MARK: Life cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        precondition(dataController != nil)
        precondition(songsService != nil)

        dataController.load { description, error in
            guard error == nil else {
                // TODO: Alert error to user.
                print("Error while loading the store.")
                return
            }

            if !UserDefaults.wereSongsSeeded {
                self.seedSongsFromJsonFile()
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    self.displayNextController()
                })
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.titleVerticalConstraint.constant -= 100
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()

        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = alphaTransitioningDelegate

        if segue.identifier == SegueIdentifiers.WarningControllerSegue,
            let warningController = segue.destination as? WarningViewController {
            warningController.songsControllerPreparationHandler = { songsController in
                self.prepareSongsController(songsController)
            }

        } else if segue.identifier == SegueIdentifiers.SongsControllerSegue {
            if let navigationController = segue.destination as? UINavigationController,
                let songsListController = navigationController.topViewController as? SongsTableViewController {
                prepareSongsController(songsListController)
            }
        }
    }

    // MARK: Imperatives

    /// Gets the json file and seeds the data store with its content.
    private func seedSongsFromJsonFile() {
        guard let songsJsonURL = Bundle.main.url(forResource: "songs", withExtension: "json"),
            let songsJsonData = try? Data(contentsOf: songsJsonURL) else {
                preconditionFailure("Couldn't retrieve the songs json data.")
        }

        songsService.handleSongsJson(songsJsonData) { error in
            guard error == nil else {
                // TODO: Alert users about the error.
                return
            }

            UserDefaults.wereSongsSeeded = true
            self.displayNextController()
        }
    }

    /// Continues with the app flow.
    private func displayNextController() {
        DispatchQueue.main.async {
            if UserDefaults.isFirstLaunch {
                // Display the warning controller before.
                self.performSegue(withIdentifier: SegueIdentifiers.WarningControllerSegue, sender: self)
            } else {
                // Display the main controller.
                self.performSegue(withIdentifier: SegueIdentifiers.SongsControllerSegue, sender: self)
            }
        }
    }

    /// Prepares the songs controller to display by injecting its dependencies.
    private func prepareSongsController(_ songsController: SongsTableViewController) {
        songsController.songStore = songsService.songsStore
        songsController.songsFetchedResultsController =
            songsService.songsStore.makeFetchedResultsControllerForAllSongs(
                usingContext: dataController.viewContext
        )
    }
}

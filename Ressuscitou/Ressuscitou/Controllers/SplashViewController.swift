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
                self.displayMainController()
            }
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.initialControllerSegue {
            if let navigationController = segue.destination as? UINavigationController,
                let songsListController = navigationController.topViewController as? SongsTableViewController {
                songsListController.songsFetchedResultsController =
                    songsService.songsStore.makeFetchedResultsControllerForAllSongs(
                        usingContext: dataController.viewContext
                )
                songsListController.songStore = songsService.songsStore
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
            self.displayMainController()
        }
    }

    /// Continues with the app flow.
    private func displayMainController() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: SegueIdentifiers.initialControllerSegue, sender: self)
        }
    }
}

extension UserDefaults {

    // MARK: Properties

    /// A flag indicating whether the songs were added into core data or not.
    static var wereSongsSeeded: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.wereSongsSeeded)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.wereSongsSeeded)
        }
    }
}

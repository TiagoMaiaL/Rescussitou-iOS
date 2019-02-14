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
                // TODO: Display error to user.
                print("Error")
                return
            }

            self.seedSongsFromJsonFile()

//            DispatchQueue.main.async {
//                self.performSegue(withIdentifier: SegueIdentifiers.initialControllerSegue, sender: self)
//            }
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
        }
    }
}

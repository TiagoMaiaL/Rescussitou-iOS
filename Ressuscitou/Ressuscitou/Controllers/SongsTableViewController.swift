//
//  SongsTableViewController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 14/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

/// A controller displaying a list of songs.
class SongsTableViewController: UITableViewController {

    // MARK: Properties

    /// The cell reuse identifier.
    private let reuseIdentifier = "song_cell"

    /// The fetched results controller of the selected category of songs.
    var songsFetchedResultsController: NSFetchedResultsController<SongMO>!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(songsFetchedResultsController != nil)

        navigationController?.navigationBar.prefersLargeTitles = true
        try! songsFetchedResultsController.performFetch()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.songControllerSegue,
            let songController = segue.destination as? SongViewController,
            let selectedIndex = tableView.indexPathForSelectedRow {
            songController.song = songsFetchedResultsController.object(at: selectedIndex)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return songsFetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsFetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        let song = songsFetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = song.title

        return cell
    }
}

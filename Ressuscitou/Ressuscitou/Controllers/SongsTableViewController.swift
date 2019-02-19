//
//  SongsTableViewController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 14/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData
import SideMenu

/// A controller displaying a list of songs.
class SongsTableViewController: UITableViewController {

    // MARK: Properties

    /// The cell reuse identifier.
    private let reuseIdentifier = "song_cell"

    /// The currently selected filter category.
    var selectedCategory: IndexPath?

    /// The fetched results controller of the selected category of songs.
    var songsFetchedResultsController: NSFetchedResultsController<SongMO>! {
        didSet {
            if songsFetchedResultsController != nil, tableView != nil {
                do {
                    try songsFetchedResultsController.performFetch()
                    tableView.reloadData()
                } catch {
                    // TODO: Display error to the user.
                }
            }
        }
    }

    /// The store used to fetch and filter the songs.
    var songStore: SongMOStoreProtocol!

    // MARK: Life cycle

    deinit {
        unsubscribeFromAllNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(songsFetchedResultsController != nil)
        precondition(songStore != nil)

        subscribeToNotification(named: .FilterSongs, usingSelector: #selector(filterSongs(_:)))

        navigationController?.navigationBar.prefersLargeTitles = true
        try! songsFetchedResultsController.performFetch()
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.SongControllerSegue,
            let songController = segue.destination as? SongViewController,
            let selectedIndex = tableView.indexPathForSelectedRow {
            songController.song = songsFetchedResultsController.object(at: selectedIndex)

        } else if segue.identifier == SegueIdentifiers.MenuControllerSegue,
            let menuNavigationController = segue.destination as? UISideMenuNavigationController {
            // Configure the menu presentation style.
            menuNavigationController.menuWidth = view.frame.width * 0.8
            menuNavigationController.sideMenuManager.menuPresentMode = .menuSlideIn
            menuNavigationController.sideMenuManager.menuAnimationFadeStrength = 0.5
            // TODO: Figure out how to add corner radius to the controller's views.

            // Inject the dependencies to the menu.
            guard let menuController = menuNavigationController.visibleViewController as? MenuTableViewController else {
                preconditionFailure("The menu controller must be set.")
            }
            menuController.songStore = songStore
            menuController.viewContext = songsFetchedResultsController.managedObjectContext
            menuController.selectedCategory = selectedCategory
        }
    }

    // MARK: Actions

    /// Filters the songs to display.
    @objc private func filterSongs(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
            let filterFetchedResultsController: NSFetchedResultsController<SongMO> =
            userInfo[UserInfoKeys.Filter] as? NSFetchedResultsController,
            let selectedCategory = userInfo[UserInfoKeys.SelectedCategory] as? IndexPath else {
                preconditionFailure("The filter frc must be set.")
        }

        // Update the listing by replacing the fetched results controller.
        songsFetchedResultsController = filterFetchedResultsController
        self.selectedCategory = selectedCategory
    }

    // MARK: Table view data source

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

//
//  SongsListingViewController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 14/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData
import SideMenu

/// A controller displaying a list of songs.
class SongsListingViewController: UIViewController {

    // MARK: Properties

    /// The cell reuse identifier.
    private let reuseIdentifier = "song_cell"

    /// The currently selected filter category.
    var selectedCategory: IndexPath?

    /// The table view displaying the songs.
    @IBOutlet weak var tableView: UITableView!

    /// The top constraint of the tableView related to its super view.
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        navigationController?.setNavigationBarHidden(false, animated: true)
        animateTableViewDisplayal()
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

        // Animate the table view out.
        animateTableViewDismissal { _ in
            // Update the listing by replacing the fetched results controller.
            self.songsFetchedResultsController = filterFetchedResultsController
            self.selectedCategory = selectedCategory

            // Animate the table view in.
            self.animateTableViewDisplayal { _ in
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .middle, animated: true)
            }
        }
    }

    /// Animates the table view in.
    /// - Parameter completionHandler: closure called when the animation completes.
    private func animateTableViewDisplayal(_ completionHandler: ((Bool) -> Void)? = nil) {
        tableViewTopConstraint.constant = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
            self.tableView.alpha = 1
        }, completion: completionHandler)
    }

    /// Animates the table view out.
    /// - Parameter completionHandler: closure called when the animation completes.
    private func animateTableViewDismissal(_ completionHandler: ((Bool) -> Void)? = nil) {
        tableViewTopConstraint.constant = 50
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
            self.tableView.alpha = 0
        }, completion: completionHandler)
    }
}

extension SongsListingViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return songsFetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsFetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier,
            for: indexPath
            ) as? SongTableViewCell else {
                preconditionFailure("The song table view cell must be set.")
        }

        let song = songsFetchedResultsController.object(at: indexPath)
        cell.titleLabel.text = song.title

        if let songColor = song.color {
            cell.dotView.isHidden = false
            cell.dotView.backgroundColor = songColor
        }
        
        return cell
    }
}

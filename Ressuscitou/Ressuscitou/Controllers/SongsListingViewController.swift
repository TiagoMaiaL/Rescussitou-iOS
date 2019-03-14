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

    /// The reuse identifier of the cells displaying the songs.
    private let reuseIdentifier = "song_cell"

    /// The reuse identifier of the header view displaying the selected category.
    private let headerViewReuseIdentifier = "header_view"

    /// The controller displaying the results of a user search.
    private lazy var searchResultsController: SearchSongsTableViewController! = {
        guard let searchTableViewController = storyboard?.instantiateViewController(
            withIdentifier: "SearchSongsTableViewController"
            ) as? SearchSongsTableViewController else {
                preconditionFailure("The controller to search for songs must be set.")
        }
        searchTableViewController.selectionHandler = { selectedSong in
            self.selectedSearchSong = selectedSong
            self.performSegue(withIdentifier: SegueIdentifiers.SongControllerSegue, sender: self)
        }

        return searchTableViewController
    }()

    /// The search controller in charge of handling the user's search.
    private var searchController: UISearchController!

    /// The song selected from the user's search, so it can be passed to the next controller.
    private var selectedSearchSong: SongMO?

    /// The table view displaying the songs.
    @IBOutlet weak var tableView: UITableView!

    /// The top constraint of the tableView related to its super view.
    /// - Note: this constraint is used to animate the table in and out after filters.
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!

    /// The fetched results controller of the selected category of songs.
    var songsFetchedResultsController: NSFetchedResultsController<SongMO>! {
        didSet {
            if songsFetchedResultsController != nil, tableView != nil {
                // Try to fetch the new FRC and display the results.
                do {
                    try songsFetchedResultsController.performFetch()
                    searchResultsController.songsToBeSearched = songsFetchedResultsController.fetchedObjects ?? []
                    tableView.reloadData()
                } catch {
                    displayFetchingError()
                }
            }
        }
    }

    /// The currently selected filter category, related to the menu table view controller.
    /// - Note: Since the menu controller is always destroyed after dismissed, this reference is passed right before
    ///         it appears, so the selected category can be displayed to the user.
    var selectedCategory = IndexPath(row: 0, section: 0)

    /// The currently selected category title, displayed in the section header.
    var selectedCategoryTitle = MenuTableViewController.Section.all.title

    /// The store used to fetch and filter the songs.
    var songStore: SongMOStoreProtocol!

    /// The service used to handle the songs using external resources.
    var songsService: SongsServiceProtocol!

    // MARK: Life cycle

    deinit {
        unsubscribeFromAllNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(songsFetchedResultsController != nil)
        precondition(songStore != nil)
        precondition(songsService != nil)

        navigationController?.delegate = self

        navigationController?.view.backgroundColor = .white
        definesPresentationContext = true
        navigationController?.navigationBar.prefersLargeTitles = true

        subscribeToNotification(named: .FilterSongs, usingSelector: #selector(filterSongs(_:)))

        do {
            try songsFetchedResultsController.performFetch()
            searchResultsController.songsToBeSearched = songsFetchedResultsController.fetchedObjects ?? []
        } catch {
            displayFetchingError()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIntexPath = tableView.indexPathForSelectedRow {
            tableView.reloadRows(at: [selectedIntexPath], with: .automatic)
            tableView.deselectRow(at: selectedIntexPath, animated: true)
        }

        if songsFetchedResultsController.delegate == nil {
            songsFetchedResultsController.delegate = self
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        if navigationController?.isNavigationBarHidden ?? false {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        animateTableViewDisplayal()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.SongControllerSegue,
            let songController = segue.destination as? SongViewController {

            var selectedSong: SongMO!

            if let searchedSong = selectedSearchSong {
                selectedSong = searchedSong
                selectedSearchSong = nil
            } else if let selectedIndex = tableView.indexPathForSelectedRow {
                selectedSong = songsFetchedResultsController.object(at: selectedIndex)
            } else {
                preconditionFailure("A song controller must always have a selected song.")
            }

            songController.song = selectedSong
            songController.songsService = songsService

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
        guard
            let userInfo = notification.userInfo as? [String: Any],
            let filterFetchedResultsController: NSFetchedResultsController<SongMO> = userInfo[UserInfoKeys.Filter]
                as? NSFetchedResultsController,
            let selectedCategory = userInfo[UserInfoKeys.SelectedCategoryIndexPath] as? IndexPath,
            let selectedCategoryTitle = userInfo[UserInfoKeys.SelectedCategoryTitle] as? String
            else {
                preconditionFailure("The filter frc must be set.")
        }

        // Animate the table view out.
        animateTableViewDismissal { _ in
            // Update the listing by replacing the fetched results controller.
            self.songsFetchedResultsController = filterFetchedResultsController
            self.selectedCategory = selectedCategory
            self.selectedCategoryTitle = selectedCategoryTitle

            // Animate the table view in.
            self.animateTableViewDisplayal { _ in
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .middle, animated: true)
            }
        }
    }

    @IBAction func search(_ sender: UIBarButtonItem) {
        self.searchController.searchBar.becomeFirstResponder()
        self.searchController.isActive = true
    }

    // MARK: Imperatives

    /// Configures the search controller to appear in the navigation bar.
    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController

        // Configure the search bar.
        searchController.searchBar.placeholder = NSLocalizedString(
            "Pesquisar",
            comment: "Placeholder text of the search bar."
        )

        searchController.searchBar.tintColor = .white
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.tintColor = .lightGray
            textField.font = UIFont(name: "Quicksand-Regular", size: 16)

            if let backgroundView = textField.subviews.first {
                backgroundView.backgroundColor = .white
                backgroundView.layer.cornerRadius = 10
            }
        }
        navigationItem.searchController = searchController
    }

    /// Animates the table view in after a filter or initial controller appearance.
    /// - Parameter completionHandler: closure called when the animation completes.
    private func animateTableViewDisplayal(_ completionHandler: ((Bool) -> Void)? = nil) {
        tableViewTopConstraint.constant = 0
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.view.layoutIfNeeded()
            self.tableView.alpha = 1
        }, completion: completionHandler)
    }

    /// Animates the table view out to display the filtered results.
    /// - Parameter completionHandler: closure called when the animation completes.
    private func animateTableViewDismissal(_ completionHandler: ((Bool) -> Void)? = nil) {
        tableViewTopConstraint.constant = 50
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.view.layoutIfNeeded()
            self.tableView.alpha = 0
        }, completion: completionHandler)
    }

    /// Displays an error alert to the user informing that the songs fetch couldn't be performed.
    private func displayFetchingError() {
        let message = NSLocalizedString(
            "Não foi possível exibir os cânticos.",
            comment: "Error message displayed when the songs can't be displayed."
        )
        present(makeErrorAlertController(withMessage: message), animated: true)
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

        cell.displayAudioIndicator(ifItHasAudio: song.hasAudio, andIfAudioWasDonwloaded: song.audio != nil)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = Bundle.main.loadNibNamed("SongTableHeaderView",
                                                        owner: self,
                                                        options: nil)?.first as? SongTableHeaderView else {
                                                            preconditionFailure("The header view must be set.")
        }

        headerView.titleLabel.text = selectedCategoryTitle

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
}

extension SongsListingViewController: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
        ) {
        if viewController is SongsListingViewController {
            // Reconfigure the search controller.
            configureSearchController()
        }
    }
}

extension SongsListingViewController: NSFetchedResultsControllerDelegate {

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
        ) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)

        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)

        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)

        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

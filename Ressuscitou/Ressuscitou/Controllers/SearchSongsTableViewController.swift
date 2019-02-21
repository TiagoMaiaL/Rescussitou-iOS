//
//  SearchSongsTableViewController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 21/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

/// Controller used to display the results of the songs search controller.
class SearchSongsTableViewController: UITableViewController {

    // MARK: Properties

    /// The reuse identifier of the cell displaying the results.
    private let reuseIdentifier = "song_cell"

    /// The selection handler called when a song is selected.
    var selectionHandler: ((SongMO) -> Void)!

    /// The songs to be searched.
    var songsToBeSearched = [SongMO]()

    /// The result of the search performed on the songs to be searched.
    private var searchResults = [SongMO]()

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(selectionHandler != nil)

        clearsSelectionOnViewWillAppear = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchResults = []
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier,
            for: indexPath
            ) as? SongTableViewCell else {
                preconditionFailure("The song cell must be set.")
        }

        let currentSong = searchResults[indexPath.row]
        cell.titleLabel.text = currentSong.title
        if let songColor = currentSong.color {
            cell.dotView.isHidden = false
            cell.dotView.backgroundColor = songColor
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionHandler(searchResults[indexPath.row])
    }
}

extension SearchSongsTableViewController: UISearchResultsUpdating {

    // MARK: UISearchResultsUpdating methods

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty else {
            searchResults = []
            tableView.reloadData()
            return
        }

        searchResults = songsToBeSearched.filter { song in
            return song.title!.lowercased().contains(searchText) ||
                song.content!.contains(searchText.replacingOccurrences(of: " ", with: ""))
        }
        tableView.reloadData()
    }
}

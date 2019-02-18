//
//  MenuTableViewController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 18/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// The controller showing the menu with the filter options.
class MenuTableViewController: UITableViewController {

    // MARK: Properties

    /// The reuse identifiers used in this controller.
    let reuseIdentifier = "menu_cell_identifier"

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        return cell
    }
}

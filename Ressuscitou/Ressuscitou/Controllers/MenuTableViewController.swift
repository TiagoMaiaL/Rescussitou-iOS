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

    // MARK: Types

    /// The sections of the menu.
    private enum Section: Int, CaseIterable {
        case stages = 0
        case liturgicalTime = 1

        /// The title assciated with the section.
        var title: String {
            switch self {
            case .stages:
                return "Etapa"
            case .liturgicalTime:
                return "Tempo Litúrgico"
            }
        }

        /// The number of rows contained in each section.
        var numberOfRows: Int {
            switch self {
            case .stages:
                return 4
            case .liturgicalTime:
                return 5
            }
        }
    }

    // MARK: Properties

    /// The reuse identifier of the menu cells.
    private let cellReuseIdentifier = "menu_cell_identifier"

    /// The reuse identifier of the header views.
    private let headerReuseIdentifier = "header_reuse_identifier"

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerReuseIdentifier)
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section(rawValue: section)?.numberOfRows ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)

        cell.textLabel?.text = "XXX"

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier),
            let section = Section(rawValue: section) else {
                preconditionFailure("Couldn't dequeue the header view.")
        }

        headerView.textLabel?.text = section.title.uppercased()
        headerView.textLabel?.textColor = .black
        // TODO: Why is the label not reading the size of the font?
        headerView.textLabel?.font = UIFont(name: "Quicksand-Bold", size: 11)
        headerView.contentView.backgroundColor = .white

        return headerView
    }
}

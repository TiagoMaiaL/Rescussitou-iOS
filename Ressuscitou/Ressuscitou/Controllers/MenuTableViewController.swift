//
//  MenuTableViewController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 18/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

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
                return NSLocalizedString("Etapa", comment: "The name of the first menu section.")
            case .liturgicalTime:
                return NSLocalizedString("Tempo Litúrgico", comment: "The name of the second menu section.")
            }
        }

        /// The number of rows contained in each section.
        var numberOfRows: Int {
            switch self {
            case .stages:
                return SongMO.StageCategory.allCases.count
            case .liturgicalTime:
                return SongMO.LiturgicalTimeCategory.allCases.count
            }
        }
    }

    // MARK: Properties

    /// The reuse identifier of the menu cells.
    private let cellReuseIdentifier = "menu_cell_identifier"

    /// The reuse identifier of the header views.
    private let headerReuseIdentifier = "header_reuse_identifier"

    /// The song store used to send the selected fetched results controller for filtering.
    var songStore: SongMOStoreProtocol!

    /// The view context used to create the fetched results controllers to filter.
    var viewContext: NSManagedObjectContext!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(songStore != nil)
        precondition(viewContext != nil)

        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerReuseIdentifier)

        UIApplication.shared.statusBarView?.backgroundColor = Colors.baseRed
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
        guard let section = Section(rawValue: indexPath.section) else { preconditionFailure("Couldn't get section.") }

        var text: String!

        switch section {
        case .stages:
            guard let currentStage = SongMO.StageCategory(rawValue: indexPath.row) else {
                preconditionFailure("Couln't get the stage category.")
            }

            text = currentStage.title
            break
        case .liturgicalTime:
            guard let currentTime = SongMO.LiturgicalTimeCategory(rawValue: indexPath.row) else {
                preconditionFailure("Couln't get the time category.")
            }

            text = currentTime.title
            break
        }

        cell.textLabel?.text = text

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else {
            preconditionFailure("Couldn't dequeue the header view.")
        }

        return section.title.uppercased()
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            preconditionFailure()
        }

        headerView.textLabel?.font = UIFont(name: "Quicksand-Bold", size: 11)
        headerView.textLabel?.textColor = .black
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}

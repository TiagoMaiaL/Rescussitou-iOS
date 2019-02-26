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
    enum Section: Int, CaseIterable {
        case all = 0
        case stages
        case liturgicalTime
        case eucarist

        /// The title assciated with the section.
        var title: String {
            switch self {
            case .all:
                return NSLocalizedString("Ver todos (A-Z)", comment: "The name of one of the menu sections.")
            case .stages:
                return NSLocalizedString("Etapa", comment: "The name of one of the menu sections.")
            case .liturgicalTime:
                return NSLocalizedString("Tempo Litúrgico", comment: "The name of one of the menu sections.")
            case .eucarist:
                return NSLocalizedString("Eucaristia", comment: "The name of one of the menu sections.")
            }
        }

        /// The number of rows contained in each section.
        var numberOfRows: Int {
            switch self {
            case .all:
                return 1
            case .stages:
                return SongMO.StageCategory.allCases.count
            case .liturgicalTime:
                return SongMO.LiturgicalTimeCategory.allCases.count
            case .eucarist:
                return SongMO.EucaristCategory.allCases.count
            }
        }
    }

    // MARK: Properties

    /// The reuse identifier of the menu cells.
    private let cellReuseIdentifier = "menu_cell_identifier"

    /// The reuse identifier of the header views.
    private let headerReuseIdentifier = "header_reuse_identifier"

    /// The index path of the selected category.
    var selectedCategory: IndexPath?

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedCategory = selectedCategory {
            tableView.selectRow(at: selectedCategory, animated: false, scrollPosition: .middle)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let selectedCategory = selectedCategory {
            tableView.scrollToRow(at: selectedCategory, at: .middle, animated: true)
        }
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section(rawValue: section)?.numberOfRows ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellReuseIdentifier,
            for: indexPath
            ) as? SongTableViewCell else {
                preconditionFailure("The menu cell must be set.")
        }
        guard let section = Section(rawValue: indexPath.section) else { preconditionFailure("Couldn't get section.") }

        var text: String!

        switch section {
        case .all:
            text = section.title
            cell.titleLabel.font = UIFont(name: "Quicksand-Bold", size: 18)
            break

        case .stages:
            guard let currentStage = SongMO.StageCategory(rawValue: indexPath.row) else {
                preconditionFailure("Couldn't get the stage category.")
            }
            cell.dotView.backgroundColor = currentStage.color
            cell.dotView.isHidden = false
            text = currentStage.title

        case .liturgicalTime:
            guard let currentTime = SongMO.LiturgicalTimeCategory(rawValue: indexPath.row) else {
                preconditionFailure("Couldn't get the time category.")
            }
            text = currentTime.title

        case .eucarist:
            guard let currentEucaristPart = SongMO.EucaristCategory(rawValue: indexPath.row) else {
                preconditionFailure("Couldn't get the eucarist category.")
            }
            text = currentEucaristPart.title
        }

        cell.titleLabel.text = text

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
        return Section(rawValue: section) == .all ? 0 : 40
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            preconditionFailure("Couldn't get the section.")
        }

        var fetchedResultsControllerForFilter: NSFetchedResultsController<SongMO>!
        var categoryTitle: String!

        switch section {
        case .all:
            fetchedResultsControllerForFilter = songStore.makeFetchedResultsControllerForAllSongs(
                usingContext: viewContext
            )
            categoryTitle = section.title

        case .stages:
            guard let stage = SongMO.StageCategory(rawValue: indexPath.row) else {
                preconditionFailure("Couldn't get the stage.")
            }
            fetchedResultsControllerForFilter = songStore.makeFetchedResultsControllerForStageCategory(
                stage,
                usingContext: viewContext
            )
            categoryTitle = stage.title

        case .liturgicalTime:
            guard let liturgicalTime = SongMO.LiturgicalTimeCategory(rawValue: indexPath.row) else {
                preconditionFailure("Couldn't get the stage.")
            }
            fetchedResultsControllerForFilter = songStore.makeFetchedResultsControllerForLiturgicalTimeCategory(
                liturgicalTime,
                usingContext: viewContext
            )
            categoryTitle = liturgicalTime.title

        case .eucarist:
            guard let eucaristPart = SongMO.EucaristCategory(rawValue: indexPath.row) else {
                preconditionFailure("Couldn't get the eucarist category.")
            }
            fetchedResultsControllerForFilter = songStore.makeFetchedResultsControllerForEucaristCategory(
                eucaristPart,
                usingContext: viewContext
            )
            categoryTitle = eucaristPart.title
        }

        NotificationCenter.default.post(
            name: .FilterSongs,
            object: self,
            userInfo: [UserInfoKeys.Filter: fetchedResultsControllerForFilter,
                       UserInfoKeys.SelectedCategoryIndexPath: indexPath,
                       UserInfoKeys.SelectedCategoryTitle: categoryTitle]
        )

        dismiss(animated: true, completion: nil)
    }
}

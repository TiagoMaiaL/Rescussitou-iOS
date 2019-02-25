//
//  EmptySearchView.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 25/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

class EmptySearchView: UIView {

    // MARK: Properties

    /// The label displaying that the results weren't found.
    @IBOutlet weak var noResultsLabel: UILabel!

    // MARK: Imperatives

    /// Configures the label to display that no results were found for the passed term.
    /// - Parameter searchTerm: the term being searched.
    func displayNoResultsText(forTerm term: String) {
        let noResultsPreText = NSLocalizedString(
            "Nenhum resultado para",
            comment: "Text shown when no results were found for a search."
        )

        noResultsLabel.text = noResultsPreText + " \"\(term)\"."
    }
}

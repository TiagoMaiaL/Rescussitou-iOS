//
//  MenuTableViewCell.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 20/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// The table view cell displaying the filter options in the menu.
class MenuTableViewCell: UITableViewCell {

    // MARK: Properties

    /// The view displaying the dot with the color of the menu category.
    @IBOutlet weak var dotView: RoundedView!

    /// The label displaying the title.
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: Initializers

    override func awakeFromNib() {
        super.awakeFromNib()
        dotView.isHidden = true
    }

    // MARK: Life cycle

    override func prepareForReuse() {
        super.prepareForReuse()
        dotView.isHidden = true
        titleLabel.font = UIFont(name: "Quicksand-Regular", size: 18)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let dotViewInitialColor = dotView.backgroundColor

        super.setSelected(selected, animated: animated)

        if dotViewInitialColor != nil {
            dotView.backgroundColor = dotViewInitialColor
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let dotViewInitialColor = dotView.backgroundColor

        super.setHighlighted(highlighted, animated: animated)

        if dotViewInitialColor != nil {
            dotView.backgroundColor = dotViewInitialColor
        }
    }
}

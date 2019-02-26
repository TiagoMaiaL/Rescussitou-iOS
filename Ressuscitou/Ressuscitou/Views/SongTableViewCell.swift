//
//  SongTableViewCell.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 20/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// The cell displaying a song.
class SongTableViewCell: UITableViewCell {

    // MARK: Properties

    /// The dot view displaying the color associated to the song.
    @IBOutlet weak var dotView: RoundedView!

    /// The label displaying name of the song.
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureInitialState()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        configureInitialState()
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

    // MARK: Imperatives

    /// Configures the cell initial state.
    private func configureInitialState() {
        dotView.isHidden = true
        dotView.backgroundColor = nil
    }
}

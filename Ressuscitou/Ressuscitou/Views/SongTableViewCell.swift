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
        dotView.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        dotView.isHidden = true
    }
}

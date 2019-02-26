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

    /// The view indicating if the song has a sound file or not.
    @IBOutlet weak var songIndicatorView: UIImageView!

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

    /// Configures the sound indicator view according to the passed parameters.
    /// - Parameters:
    ///     - hasSound: indicates if the song being displayed has a soung associated with it.
    ///     - wasDownloaded: indicates if the song was already downloaded or not.
    func displaySoundIndicator(ifItHasSound hasSound: Bool, andIfSoundWasDonwloaded wasDownloaded: Bool) {
        songIndicatorView.isHidden = !hasSound
        songIndicatorView.image = UIImage(
            named: wasDownloaded ? "content-download-icon-on" : "content-download-icon-off"
        )
    }

    /// Configures the cell initial state.
    private func configureInitialState() {
        titleLabel.font = UIFont(name: "Quicksand-Regular", size: 18)
        dotView.isHidden = true
        dotView.backgroundColor = nil
        songIndicatorView.isHidden = true
    }
}

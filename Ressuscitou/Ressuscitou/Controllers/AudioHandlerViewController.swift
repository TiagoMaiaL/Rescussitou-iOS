//
//  AudioHandlerViewController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 27/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Controller in charge of downloading and playing the audios of the songs.
class AudioHandlerViewController: UIViewController {

    // MARK: Properties

    /// The current song having the audio to be handled.
    var song: SongMO!

    /// The service in charge of downloading the audio related to the song.
    var songsService: SongsServiceProtocol!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(song != nil)
        precondition(song.hasAudio)
        precondition(songsService != nil)
    }
}

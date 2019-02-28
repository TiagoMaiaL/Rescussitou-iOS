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

    /// The stack view holding the audio loading controls.
    @IBOutlet weak var loadingContainerView: UIStackView!

    /// The indicator telling the user if the audio is being loaded.
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!

    /// The label informing about the loading state.
    @IBOutlet weak var loadingLabel: UILabel!

    /// The download task currently running.
    private var downloadTask: URLSessionDownloadTask?

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(song != nil)
        precondition(song.hasAudio)
        precondition(songsService != nil)

        loadingActivityIndicator.stopAnimating()
    }

    // MARK: Imperatives

    /// Animates the initial visual state of the controller.
    func animateViewsIn() {
        if song.audio == nil {
            // Display the download container view.

            self.loadingActivityIndicator.startAnimating()

            UIView.animate(withDuration: 0.2, animations: {
                self.loadingContainerView.alpha = 1
            }) { isCompleted in
                if isCompleted {
                    self.completeDisplayAnimation()
                }
            }
        } else {
            // Display the player.
            // TODO: Display the player.
        }
    }

    /// Animates the controller views out.
    func animateViewsOut() {
        // Hide all views.
        self.loadingActivityIndicator.stopAnimating()

        UIView.animate(withDuration: 0.2) {
            self.loadingContainerView.alpha = 0
        }
    }

    /// Completes the animation by showing the audio player or starting the
    /// download of the song.
    private func completeDisplayAnimation() {
        if song.audio == nil, downloadTask == nil {
            // Download the song.
            self.loadingLabel.text = NSLocalizedString(
                "Baixando o áudio do cântico...",
                comment: "Label shown while the audio is being downloaded."
            )

            print("Starting the download task.")
            downloadTask = self.songsService.downloadSound(fromSong: song) { wasDownloadSuccessful, error in

                self.downloadTask = nil

                guard error == nil, wasDownloadSuccessful == true else {
                    // TODO: Display error to the user.
                    switch error! {
                    case SongsServiceError.internetConnection:
                        print("Internet connection problem.")

                    case SongsServiceError.serverNotAvailable:
                        print("Server not available.")

                    case SongsServiceError.resourceNotAvailable:
                        print("Resource not available.")

                    case SongsServiceError.readResource:
                        print("Couldn't read the resource.")

                    }

                    return
                }

                DispatchQueue.main.async {
                    print("Download sucessful!!")
                    // TODO: Show player.
                    self.loadingLabel.text = nil
                    self.loadingActivityIndicator.stopAnimating()
                }
            }
        } else {
            // Load the song and the player.
        }
    }
}

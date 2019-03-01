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

    /// The stack view holding the audio player controls.
    @IBOutlet weak var playerContainerView: UIStackView!

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
        UIView.animate(withDuration: 0.2, animations: {
            /// Displays the loading container view.
            func displayLoading(active: Bool = true) {
                self.loadingContainerView.isHidden = !active

                if active {
                    self.loadingActivityIndicator.startAnimating()
                } else {
                    self.loadingActivityIndicator.stopAnimating()
                }

                self.loadingContainerView.alpha = active ? 1 : 0
            }

            /// Displays the player container view.
            func displayPlayer(active: Bool = true) {
                self.playerContainerView.isHidden = !active
                self.playerContainerView.alpha = active ? 1 : 0
            }

            if self.song.audio == nil {
                // Display the loading container view.
                displayLoading()
                displayPlayer(active: false)
            } else {
                // Display the audio player.
                displayPlayer()
                displayLoading(active: false)
            }
        }) { isCompleted in
            self.completeDisplayAnimation()
        }
    }

    /// Animates the controller views to the state of dismissal, when the controller disappears.
    func animateViewsOut() {
        // Hide all views.
        self.loadingActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2) {
            [self.playerContainerView, self.loadingContainerView].forEach {
                $0?.alpha = 0
                $0?.isHidden = true
            }
        }
    }

    /// Completes the animation by showing the audio player or starting the download of the song.
    private func completeDisplayAnimation() {
        if song.audio == nil, downloadTask == nil {
            // Download the song.
            self.loadingLabel.text = NSLocalizedString(
                "Baixando o áudio do cântico...",
                comment: "Label shown while the audio is being downloaded."
            )

            print("Starting the download task.")
            downloadTask = self.songsService.downloadAudio(fromSong: song) { wasDownloadSuccessful, error in

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
                    self.loadingLabel.text = nil
                    self.loadingActivityIndicator.stopAnimating()

                    self.animateViewsIn()
                }
            }
        }
    }
}

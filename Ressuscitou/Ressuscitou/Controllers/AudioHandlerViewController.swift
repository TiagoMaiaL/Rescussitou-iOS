//
//  AudioHandlerViewController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 27/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import AVFoundation

/// Controller in charge of downloading and playing the audios of the songs.
class AudioHandlerViewController: UIViewController {

    // MARK: Properties

    /// The current song having the audio to be handled.
    var song: SongMO!

    /// The player used to play the audio of the song.
    var audioPlayer: AVAudioPlayer?

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

    /// The button used to play/pause the audio.
    @IBOutlet weak var playbackButton: UIButton!

    /// The label displaying the current playback time of the audio.
    @IBOutlet weak var currentPlaybackTimeLabel: UILabel!

    /// The label displaying the duration of the audio being played.
    @IBOutlet weak var audioTimeDurationLabel: UILabel!

    /// A timer used to update the UI with the current playback status.
    private var playbackUpdateTimer: Timer?

    /// The playback slider used to control the time of the audio.
    @IBOutlet weak var playbackSlider: UISlider!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(song != nil)
        precondition(song.hasAudio)
        precondition(songsService != nil)

        loadingActivityIndicator.stopAnimating()

        setupAudioPlayer()
    }

    // MARK: Setup

    /// Sets up the audio player related to the song, if the song has a downloaded audio.
    private func setupAudioPlayer() {
        guard let audio = song.audio else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(data: audio, fileTypeHint: AVFileType.mp3.rawValue)
            audioPlayer!.prepareToPlay()
            audioPlayer!.delegate = self
            audioTimeDurationLabel.text = getFormattedPlaybackTime(fromTimeInterval: audioPlayer!.duration)
        } catch {
            // TODO: Display error to user.
        }
    }

    // MARK: Actions

    @IBAction func setAudioCurrentTime(_ sender: UISlider) {
        guard let audioPlayer = audioPlayer else { return }

        let value = Double(sender.value)

        DispatchQueue.global(qos: .userInteractive).async {
            audioPlayer.currentTime = value * audioPlayer.duration

            DispatchQueue.main.async {
                self.currentPlaybackTimeLabel.text = self.getFormattedPlaybackTime(
                    fromTimeInterval: audioPlayer.currentTime
                )
            }
        }
    }

    @IBAction func playOrPauseAudio(_ sender: UIButton) {
        guard let audioPlayer = audioPlayer else { return }

        if audioPlayer.isPlaying {
            audioPlayer.pause()

            // Stop the interface update timer by killing it.
            playbackUpdateTimer?.invalidate()
            playbackUpdateTimer = nil
        } else {
            audioPlayer.play()

            // Start the interface update timer.
            if playbackUpdateTimer == nil {
                playbackUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    self.currentPlaybackTimeLabel.text = self.getFormattedPlaybackTime(
                        fromTimeInterval: audioPlayer.currentTime
                    )

                    self.playbackSlider.value = Float(audioPlayer.currentTime / audioPlayer.duration)

                    let playbackButtonImage = UIImage(
                        named: audioPlayer.isPlaying ? "top-pause-icon" : "top-play-icon"
                    )
                    if playbackButtonImage != self.playbackButton.image(for: .normal)! {
                        self.playbackButton.setImage(playbackButtonImage, for: .normal)
                    }
                }
            }
        }

        sender.setImage(UIImage(named: audioPlayer.isPlaying ? "top-pause-icon" : "top-play-icon"), for: .normal)
    }

    // MARK: Imperatives

    /// Formats the passed time interval into a text of minutes and seconds.
    /// - Parameter time: the interval to be formatted.
    /// - Returns: the string containing the minutes and seconds.
    private func getFormattedPlaybackTime(fromTimeInterval timeInterval: TimeInterval) -> String {
        let minutes = Int(floor(timeInterval / 60))
        let seconds = Int(floor(timeInterval.truncatingRemainder(dividingBy: 60)))

        return String(format: "%02d:%02d", minutes, seconds)
    }

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
                    self.loadingLabel.text = nil
                    self.loadingActivityIndicator.stopAnimating()

                    self.setupAudioPlayer()
                    self.animateViewsIn()
                    self.playOrPauseAudio(self.playbackButton)
                }
            }
        }
    }
}

extension AudioHandlerViewController: AVAudioPlayerDelegate {

    // MARK: Allow audio player

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playbackUpdateTimer?.fire()
        playbackUpdateTimer?.invalidate()
        playbackUpdateTimer = nil
    }
}

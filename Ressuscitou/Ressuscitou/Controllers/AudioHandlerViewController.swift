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

    /// The playback slider used to control the time of the audio.
    @IBOutlet weak var playbackSlider: UISlider!

    /// A timer used to update the UI with the current playback status.
    private var playbackUserInterfaceUpdater: Timer?

    /// A timer used to delay the change in the current time of the player, only when necessary.
    private var playerTimeScheduledChanger: Timer?

    /// The closure called when the controller needs to be dismissed from it's container controller.
    var dismissAudioHandler: (() -> Void)!

    // MARK: Life Cycle

    deinit {
        playbackUserInterfaceUpdater?.invalidate()
        playerTimeScheduledChanger?.invalidate()
        audioPlayer?.stop()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(song != nil)
        precondition(song.hasAudio)
        precondition(songsService != nil)
        precondition(dismissAudioHandler != nil)

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
            let message = NSLocalizedString(
                "Não foi possível tocar o áudio do cântico.",
                comment: "The error message sent when the audio player fails to play the audio."
            )
            let alert = makeErrorAlertController(withMessage: message) { _ in
                self.dismissAudioHandler()
            }
            present(alert, animated: true)
        }
    }

    // MARK: Actions

    /// Sets the current playback time of the audio every time the slider is changed.
    /// - Note: Since this action is called a lot of times by the slider, its wise to delay the actual change a little,
    ///         and make it happen once after a specified amount of time.
    @IBAction func changeAudioCurrentTime(_ sender: UISlider) {
        guard let audioPlayer = audioPlayer else { return }

        let value = Double(sender.value)

        // Update the current time label of the player.
        currentPlaybackTimeLabel.text = getFormattedPlaybackTime(
            fromTimeInterval: value * audioPlayer.duration
        )

        playerTimeScheduledChanger?.invalidate()
        playerTimeScheduledChanger = nil
        // Invalidate the interface updater, since the current time will be changed.
        playbackUserInterfaceUpdater?.invalidate()
        playbackUserInterfaceUpdater = nil

        // Schedule a timer to change the playback time.
        playerTimeScheduledChanger = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [unowned self] _ in
            DispatchQueue.global(qos: .userInteractive).async {
                let wasAudioPlaying = audioPlayer.isPlaying

                audioPlayer.stop()
                audioPlayer.currentTime = value * audioPlayer.duration

                if wasAudioPlaying {
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                }

                DispatchQueue.main.async {
                    self.playbackUserInterfaceUpdater = self.makeUserInterfaceUpdater()
                }
            }
        }
    }

    @IBAction func playOrPauseAudio(_ sender: UIButton) {
        guard let audioPlayer = audioPlayer else { return }

        if audioPlayer.isPlaying {
            audioPlayer.pause()

            // Stop the interface update timer by killing it.
            playbackUserInterfaceUpdater?.invalidate()
            playbackUserInterfaceUpdater = nil
        } else {
            audioPlayer.play()

            // Start the interface update timer.
            if playbackUserInterfaceUpdater == nil {
                playbackUserInterfaceUpdater = makeUserInterfaceUpdater()
            }
        }

        sender.setImage(UIImage(named: audioPlayer.isPlaying ? "top-pause-icon" : "top-play-icon"), for: .normal)
    }

    // MARK: Imperatives

    /// Generates a new user interface updating timer used to update the player controls while it's running.
    /// - Returns: the configured timer, if there's an audio player to be played.
    private func makeUserInterfaceUpdater() -> Timer? {
        guard let audioPlayer = audioPlayer else { return nil }

        return Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [unowned self] _ in
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
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
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
        }) { _ in
            self.downloadAudioIfNeeded()
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

    /// Starts the download of the audio, if not yet downloaded.
    private func downloadAudioIfNeeded() {
        if song.audio == nil, downloadTask == nil {
            // Download the song.
            self.loadingLabel.text = NSLocalizedString(
                "Baixando o áudio do cântico...",
                comment: "Label shown while the audio is being downloaded."
            )

            downloadTask = self.songsService.downloadAudio(fromSong: song) { [weak self] wasDownloadSuccessful, error in
                guard let self = self else { return }

                self.downloadTask = nil

                guard error == nil, wasDownloadSuccessful == true else {
                    self.displayDownloadError(error!)
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

    /// Displays the download error as an alert to the user.
    /// - Parameter error: the error to be displayed to the user.
    private func displayDownloadError(_ error: SongsServiceError) {
        var alert: UIAlertController!

        switch error {
        case SongsServiceError.internetConnection:
            let message = NSLocalizedString(
                "Não foi possivel fazer o donwload do cântico. Por favor, verifique a sua conexão com a internet e tente novamente.",
                comment: "Error message sent when the user doesn't have access to the internet."
            )
            alert = self.makeErrorAlertController(
                withMessage: message,
                actionTitle: "Tentar novamente",
                andDefaultActionHandler: { action in
                    // Try downloading the audio again.
                    self.downloadTask = nil
                    self.downloadAudioIfNeeded()
            })
            alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive) { _ in
                self.dismissAudioHandler()
            })

        case SongsServiceError.serverNotAvailable:
            let message = NSLocalizedString(
                "O servidor se encontra indisponível no momento, por favor, tente novamente mais tarde.",
                comment: "Error message sent when the server isn't available."
            )
            alert = self.makeErrorAlertController(withMessage: message)

        case SongsServiceError.resourceNotAvailable:
            let message = NSLocalizedString(
                "Infelizmente o áudio do cântico não está disponível para download. Por favor, contate os desenvolvedores.",
                comment: "Error message sent when the audio isn't available."
            )
            alert = self.makeErrorAlertController(withMessage: message)

        case SongsServiceError.readResource:
            let message = NSLocalizedString(
                "Não foi possível armazenar o áudio do cântico. Por favor, verifique o espaço disponível no seu celular.",
                comment: "Error message sent when the audio couldn't be persisted."
            )
            alert = self.makeErrorAlertController(withMessage: message)
        }

        self.present(alert, animated: true)
    }
}

extension AudioHandlerViewController: AVAudioPlayerDelegate {

    // MARK: Allow audio player

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playbackUserInterfaceUpdater?.fire()
        playbackUserInterfaceUpdater?.invalidate()
        playbackUserInterfaceUpdater = nil
    }
}

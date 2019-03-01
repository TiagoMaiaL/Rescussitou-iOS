//
//  SongViewController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import WebKit

/// A view controller displaying an specific song.
class SongViewController: UIViewController {

    // MARK: Properties

    /// The options bar button, used to display additional options of HTML visualization.
    @IBOutlet weak var optionsBarButton: UIBarButtonItem!

    /// The audio button used to display the player.
    @IBOutlet weak var audioBarButton: UIBarButtonItem!

    /// The web view displaying the html associated to the song.
    @IBOutlet weak var songWebView: WKWebView!

    /// The top constraint of the audio handler to be animated in and out.
    @IBOutlet weak var audioHandlerTopConstraint: NSLayoutConstraint!

    /// The height constraint of the audio handler used to correctly animate its view out of the screen.
    @IBOutlet weak var audioHandlerHeightConstraint: NSLayoutConstraint!

    /// The container view holding the audio handler controller.
    @IBOutlet weak var audioHandlerContainer: UIView!

    /// Indicates if the audio handler is being displayed or not.
    private var isDisplayingAudioHandler: Bool {
        return audioHandlerTopConstraint.constant == 0
    }

    /// The songs service used to download audios if requested.
    var songsService: SongsServiceProtocol!

    /// The song to be displayed.
    var song: SongMO!

    /// The audio handler child controller.
    var audioHandlerChildController: AudioHandlerViewController?

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(song != nil)
        precondition(songsService != nil)

        title = song.title

        if !song.hasAudio {
            navigationItem.setRightBarButtonItems([optionsBarButton], animated: false)
        }

        // Make the html responsive.
        guard let encodedHtml = song.base64HTML,
            let decodedHtmlData = Data(base64Encoded: encodedHtml),
            var html = String(data: decodedHtmlData, encoding: .utf8),
            let headRange = html.range(of: "<head>") else {
                preconditionFailure("Couldn't load the song html.")
        }
        html.insert(
            contentsOf: "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
            at: headRange.upperBound
        )
        songWebView.loadHTMLString(html, baseURL: nil)
    }

    // MARK: Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SegueIdentifiers.AudioHandlerControllerSegue {
            return song.hasAudio
        }

        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.AudioHandlerControllerSegue {
            guard let audioHandlerController = segue.destination as? AudioHandlerViewController else {
                preconditionFailure("The audio handler must be set.")
            }
            audioHandlerController.song = song
            audioHandlerController.songsService = songsService

            audioHandlerChildController = audioHandlerController
        }
    }

    // MARK: Actions

    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func displayPlayer(_ sender: UIBarButtonItem) {
        audioHandlerContainer.isHidden = false

        // Toggle the displayal of the audio handler view.
        audioHandlerTopConstraint.constant =
            isDisplayingAudioHandler ? -audioHandlerHeightConstraint.constant : 0

        if isDisplayingAudioHandler {
            audioHandlerChildController?.animateViewsIn()
        } else {
            audioHandlerChildController?.animateViewsOut()
        }

        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) { isCompleted in
            if isCompleted {
                self.audioHandlerContainer.isHidden = !self.isDisplayingAudioHandler
            }
        }
    }
}

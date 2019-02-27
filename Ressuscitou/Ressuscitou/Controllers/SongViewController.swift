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

    /// The options bar button.
    @IBOutlet weak var optionsBarButton: UIBarButtonItem!

    /// The audio button used to display the player.
    @IBOutlet weak var audioBarButton: UIBarButtonItem!

    /// The web view displaying the html associated to the song.
    @IBOutlet weak var songWebView: WKWebView!

    /// The song to be displayed.
    var song: SongMO!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(song != nil)

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

    // MARK: Actions

    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func displayPlayer(_ sender: UIBarButtonItem) {
        // TODO: Display the audio player.
    }
}

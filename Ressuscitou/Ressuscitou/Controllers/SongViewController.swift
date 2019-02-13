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

    /// The web view displaying the html associated to the song.
    @IBOutlet weak var songWebView: WKWebView!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let songsJsonURL = Bundle.main.url(forResource: "songs", withExtension: "json"),
            let songsJsonData = try? Data(contentsOf: songsJsonURL) else {
                preconditionFailure("Couldn't retrieve the songs json data.")
        }

        guard let jsonObject = try? JSONSerialization.jsonObject(
            with: songsJsonData,
            options: .allowFragments
        ), let songs = jsonObject as? [[String: Any]] else {
                preconditionFailure("Couldn't parse the songs json.")
        }

        let firstSong = songs.first!

        guard let encodedSongHtml = firstSong["html_base64"] as? String else {
            return
        }
        let decodedSongData = Data(base64Encoded: encodedSongHtml)!
        songWebView.loadHTMLString(String(data: decodedSongData, encoding: .utf8)!, baseURL: nil)
    }
}

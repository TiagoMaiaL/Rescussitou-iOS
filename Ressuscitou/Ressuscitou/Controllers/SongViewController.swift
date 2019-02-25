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

    /// The song to be displayed.
    var song: SongMO!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(song != nil)

        title = song.title

        navigationItem.searchController = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Display the song html.
        if let encodedHtml = song.base64HTML,
            let decodedHtml = Data(base64Encoded: encodedHtml),
            let html = String(data: decodedHtml, encoding: .utf8) {
            songWebView.loadHTMLString(html, baseURL: nil)
        }
    }

    // MARK: Actions

    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

//
//  SongViewController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import WebKit
import Popover

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

    /// The options popover being currently displayed.
    private var popover: Popover?

    /// The view displaying additional actions the user can take.
    @IBOutlet var optionsView: RoundedView!

    /// Indicates if the audio handler is being displayed or not.
    private var isDisplayingAudioHandler: Bool {
        return audioHandlerTopConstraint.constant == 0
    }

    /// The bottom constraint of the autoScroll container.
    @IBOutlet weak var autoScrollBottomConstraint: NSLayoutConstraint!

    /// The container holding the controls in charge of manipulating the auto scroll feature.
    @IBOutlet weak var autoScrollContainer: UIStackView!

    /// The button used to play or pause the auto scroll.
    @IBOutlet weak var autoScrollControlButton: UIButton!

    /// The button used to stop and close the auto scroll.
    @IBOutlet weak var autoScrollCloseButton: UIButton!

    /// The slider specifying the amount scrolled so far.
    @IBOutlet weak var autoScrollSlider: UISlider!

    /// Flag indicating if the auto scroll container is being shown or not.
    private var isDisplayingAutoScrollContainer: Bool {
        return autoScrollBottomConstraint.constant == 0
    }

    /// The timer in charge of scroll the webview down every n seconds.
    private var autoScrollHandler: Timer?
    
    /// The songs service used to download audios if requested.
    var songsService: SongsServiceProtocol!

    /// The song to be displayed.
    var song: SongMO!

    /// The audio handler child controller.
    var audioHandlerChildController: AudioHandlerViewController?

    // MARK: Life cycle

    deinit {
        autoScrollHandler?.invalidate()
        autoScrollHandler = nil
    }

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enableAutoScrollContainer(false)
        // Hide the container's superView, so it doesn't appear while the content of the webview is being loaded.
        autoScrollContainer.superview?.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        autoScrollContainer.superview?.isHidden = false
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
            audioHandlerController.dismissAudioHandler = { [unowned self] in
                self.displayPlayer(self.audioBarButton)
            }

            audioHandlerChildController = audioHandlerController
        }
    }

    // MARK: Actions

    @IBAction func showOptions(_ sender: UIBarButtonItem) {
        optionsView.isHidden = false

        if popover == nil {
            popover = Popover(options: [
                .arrowSize(.zero),
                .animationIn(0.3),
                .animationOut(0.1)
                ])
        }

        optionsView.sizeToFit()
        optionsView.frame = CGRect(x: 0, y: 0, width: 300, height: optionsView.frame.height)
        popover!.show(optionsView, fromView: navigationController!.navigationBar)

        optionsView.topAnchor.constraint(equalTo: popover!.topAnchor).isActive = true
        optionsView.leadingAnchor.constraint(equalTo: popover!.leadingAnchor).isActive = true
        optionsView.widthAnchor.constraint(equalTo: popover!.widthAnchor).isActive = true

        optionsView.setNeedsLayout()
    }

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

    @IBAction func beginOrCancelAutoScroll(_ sender: UIButton) {
        (isDisplayingAutoScrollContainer ? stopAutoScroll : beginAutoScroll)()
        enableAutoScrollContainer(!isDisplayingAutoScrollContainer)
        popover?.dismiss()
    }

    @IBAction func stopAndCloseAutoScroll(_ sender: UIButton) {
        stopAutoScroll()
        enableAutoScrollContainer(false)
    }

    @IBAction func playOrPauseAutoScroll(_ sender: UIButton) {
        toggleAutoScroll()
    }

    @IBAction func changeAutoScrollVelocity(_ sender: UISlider) {
        // If the auto scroll is running, change its velocity by resetting it.
        if autoScrollHandler != nil {
            stopAutoScroll()
            beginAutoScroll()
        }
    }

    // MARK: Imperatives

    /// Displays or hides the auto scroll container view, based on the provided flag.
    private func enableAutoScrollContainer(_ isEnabled: Bool) {
        let safeAreaBottomHeight = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        autoScrollBottomConstraint.constant = isEnabled ? 0 : -(60 + safeAreaBottomHeight)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.autoScrollContainer.alpha = isEnabled ? 1 : 0
        }
    }

    /// Creates the auto scroll handler, configured with the user selected scroll velocity.
    /// - Note: The scroll velocity is a value that ranges from 5 pixels per second, to 25 pixels per second.
    private func makeAutoScrollHandler() -> Timer {
        // A second divided according to the selected slider value (which ranges from 5 to 25 pixels).
        let timeIntervalVelocity = Double(1 / autoScrollSlider.value)

        return Timer.scheduledTimer(withTimeInterval: timeIntervalVelocity, repeats: true) { [unowned self] _ in
            self.songWebView.evaluateJavaScript("window.scrollBy(0, 1)")
        }
    }

    /// Toggles the auto scroll functionality of the webview.
    private func toggleAutoScroll() {
        if autoScrollHandler == nil {
            beginAutoScroll()
        } else {
            stopAutoScroll()
        }
    }

    /// Begins the auto scroll by initializing the handler.
    private func beginAutoScroll() {
        if autoScrollHandler == nil {
            autoScrollHandler = makeAutoScrollHandler()
        }
        autoScrollControlButton.setImage(UIImage(named: "bottom-pause_auto_scroll-icon")!, for: .normal)
    }

    /// Stops the auto scroll by destroying the handler.
    private func stopAutoScroll() {
        if autoScrollHandler != nil {
            autoScrollHandler!.invalidate()
            autoScrollHandler = nil
        }
        autoScrollControlButton.setImage(UIImage(named:"bottom-play_auto_scroll-icon")!, for: .normal)
    }
}

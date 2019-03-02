//
//  UIViewController+Alerts.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 02/03/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

extension UIViewController {

    // MARK: Imperatives

    /// Creates a default error alert configured with the passed message.
    /// - Parameter message: the message to be displayed to the user.
    /// - Returns: the configured error alert controller.
    func makeErrorAlertController(withMessage message: String) -> UIAlertController {
        let alert = makeAlertController(
            withTitle: NSLocalizedString("Error", comment: "The title of the alert to be displayed."),
            andMessage: message
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Ok", comment: "The title of the default alert action."),
            style: .default
        ))

        return alert
    }

    /// Creates an alert configured with the passed title and message.
    /// - Parameters:
    ///     - title: the title of the alert.
    ///     - message: the message of the alert.
    /// - Returns: the configured alert controller.
    func makeAlertController(withTitle title: String, andMessage message: String) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
}

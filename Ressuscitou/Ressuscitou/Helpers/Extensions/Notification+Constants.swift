//
//  Notification+Constants.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 18/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let FilterSongs = Notification.Name(rawValue: "filter")
}

extension UIViewController {

    // MARK: Notification imperatives

    /// Unsubscribes from all notifications.
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    /// Starts observing the specified notification.
    /// - Parameters:
    ///     - name: the name of the notification to be observed.
    ///     - selector: the selector to be called when the notification is received.
    func subscribeToNotification(named name: Notification.Name, usingSelector selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
}

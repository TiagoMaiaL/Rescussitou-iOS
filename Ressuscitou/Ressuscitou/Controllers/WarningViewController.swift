//
//  WarningViewController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 19/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

class WarningViewController: UIViewController {

    // MARK: Actions

    @IBAction func dismissWarning(_ sender: UIButton) {
        dismiss(animated: true) {
            UserDefaults.isFirstLaunch = false
        }
    }
}

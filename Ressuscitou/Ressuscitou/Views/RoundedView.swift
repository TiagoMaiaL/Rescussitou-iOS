//
//  RoundedView.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 20/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// A simple view displaying its corner radius within storyboards and xibs.
@IBDesignable
class RoundedView: UIView {

    // MARK: Properties

    /// The corner radius of the view.
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    // MARK: Life cycle

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setNeedsDisplay()
    }
}

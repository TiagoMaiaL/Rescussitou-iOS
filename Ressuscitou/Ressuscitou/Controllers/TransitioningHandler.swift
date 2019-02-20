//
//  TransitioningHandler.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 20/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// The transitoning delegate used to perform an alpha animation between the controllers.
class AlphaTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    // MARK: UIViewControllerTransitioningDelegate methods

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlphaPresentationAnimator(transitionDuration: 0.3)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AlphaPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

/// A presentation animator that performs alpha animations on the controllers to be presented.
class AlphaPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: Properties

    /// The duration of the alpha transition.
    private let transitionDuration: Double

    // MARK: Initializers

    init(transitionDuration: Double) {
        self.transitionDuration = transitionDuration
        super.init()
    }

    // MARK: Life cycle

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.viewController(forKey: .from)?.view else {
                preconditionFailure("The involved controllers must be set.")
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        containerView.addSubview(fromView)

        let propertyAnimator = UIViewPropertyAnimator(duration: transitionDuration, curve: .easeInOut) {
            fromView.alpha = 0
        }
        propertyAnimator.addCompletion { _ in
            transitionContext.completeTransition(true)
        }
        propertyAnimator.startAnimation()
    }
}

/// A presentation controller supporting the alpha transitions.
class AlphaPresentationController: UIPresentationController {

    override func presentationTransitionWillBegin() {
        presentingViewController.view.superview?.sendSubviewToBack(presentingViewController.view)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        presentingViewController.view.isHidden = true
        presentingViewController.view.removeFromSuperview()
    }
}

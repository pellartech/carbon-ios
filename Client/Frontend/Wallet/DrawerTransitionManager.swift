//
//  DrawerTransitionManager.swift
//  Client
//
//  Created by Ashok on 03/05/23.
//

import UIKit

// MARK: - UIViewControllerAnimatedTransitioning
class DrawerSlideAnimation: NSObject, UIViewControllerAnimatedTransitioning {

    var isPresenting: Bool = true

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let key: UITransitionContextViewControllerKey = isPresenting ? .to : .from
        guard let presentedController = transitionContext.viewController(forKey: key) else {
            return
        }

        let containerView = transitionContext.containerView
        let presentedFrame = transitionContext.finalFrame(for: presentedController)
        let dismissedFrame = presentedFrame.offsetBy(dx: -presentedFrame.width, dy: 0)

        if isPresenting {
            containerView.addSubview(presentedController.view)
        }

        let duration = transitionDuration(using: transitionContext)
        let wasCancelled = transitionContext.transitionWasCancelled

        let fromFrame = isPresenting ? dismissedFrame : presentedFrame
        let toFrame = isPresenting ? presentedFrame : dismissedFrame

        presentedController.view.frame = fromFrame

        UIView.animate(withDuration: duration) {
            presentedController.view.frame = toFrame
        } completion: { (_) in
            transitionContext.completeTransition(!wasCancelled)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
class DrawerTransitionManager: NSObject, UIViewControllerTransitioningDelegate {

    let slideAnimation = DrawerSlideAnimation()

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DrawerPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        slideAnimation.isPresenting = true
        return slideAnimation
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        slideAnimation.isPresenting = false
        return slideAnimation
    }
}

// MARK: - UIPresentationController
class DrawerPresentationController: UIPresentationController {

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width * 0.75, height: parentSize.height - 120)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        guard let containerView = containerView else {
            return frame
        }
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView.bounds.size)
        frame.origin.y = 120
        return frame
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedController))
        view.addGestureRecognizer(tapRecognizer)
        return view
    }()

    @objc private func dismissPresentedController() {
        presentedViewController.dismiss(animated: true)
    }

    override func presentationTransitionWillBegin() {
        guard  let containerView = containerView else {
            return
        }

        containerView.insertSubview(dimmingView, at: 0)
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1
            return
        }
        coordinator.animate { (_) in
            self.dimmingView.alpha = 1
        }
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0
            return
        }
        coordinator.animate { (_) in
            self.dimmingView.alpha = 0
        }
    }
}

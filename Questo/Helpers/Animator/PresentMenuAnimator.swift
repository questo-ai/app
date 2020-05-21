//
//  PresentMenuAnimator.swift
//  Questo
//
//  Created by Taichi Kato on 31/8/17.
//  Copyright © 2017 Questo Inc. All rights reserved.
//

import UIKit
import AVFoundation

class PresentMenuAnimator : NSObject {

}

extension PresentMenuAnimator : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false)
        else {
            return
        }
        let containerView = transitionContext.containerView
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)

        snapshot.tag = MenuHelper.snapshotNumber
        snapshot.isUserInteractionEnabled = false
        snapshot.layer.shadowOpacity = 0.7
        containerView.insertSubview(snapshot, aboveSubview: toVC.view)
        fromVC.view.isHidden = true

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
//                snapshot.frame = CGRect(x: 0, y: 20, width: snapshot.frame.width, height: snapshot.frame.height - 40)
                snapshot.center.x += UIScreen.main.bounds.width * MenuHelper.menuWidth
            },
            completion: { _ in
                fromVC.view.isHidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
        
    }
}

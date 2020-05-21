//
//  LoadingView.swift
//  Questo
//
//  Created by Taichi Kato on 25/5/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import UIKit
import Lottie

class LoadingView: UIView {
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var closeButton: UIButton!

    override func awakeFromNib() {
        self.backgroundColor = .white
        animationView.animation = Animation.named("animation-w700-h700")
        animationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        animationView.center = self.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

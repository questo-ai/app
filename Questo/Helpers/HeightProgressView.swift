//
//  HeightProgressView.swift
//  Questo
//
//  Created by Taichi Kato on 14/7/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import UIKit

class HeightProgressView: UIProgressView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maskLayerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 3.0)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskLayerPath.cgPath
        layer.mask = maskLayer
    }
}

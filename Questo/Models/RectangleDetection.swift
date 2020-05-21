//
//  RectangleDetection.swift
//  Questo
//
//  Created by Taichi Kato on 23/1/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import Vision
import UIKit

class RectangleDetection: NSObject {
    public static func detectRectangle(image: CVImageBuffer) -> VNRectangleObservation?{
        var rect: VNRectangleObservation?
        let request = VNDetectRectanglesRequest {
            (request, error) in
            if let observations = request.results as? [VNRectangleObservation]{
                if observations.count == 0{
                    rect =  nil
                }else{
                    rect = observations[0]
                }
            }
        }
        request.minimumSize = 0.2
        request.maximumObservations = 1
        let requestHandler = VNSequenceRequestHandler()
        try! requestHandler.perform([request], on: image, orientation: .rightMirrored)
        return rect
    }
    public static var rect: VNRectangleObservation? = nil
    public static func detectRectangle(image: CIImage, orientation: CGImagePropertyOrientation) -> VNRectangleObservation?{
        let request = VNDetectRectanglesRequest {
            (request, error) in
            if let observations = request.results as? [VNRectangleObservation]{
                if observations.count == 0{
                    self.rect =  nil
                }else{
                    self.rect = observations[0]
                }
            }
        }
        request.minimumSize = 0.2
        request.maximumObservations = 1
        let requestHandler = VNSequenceRequestHandler()
        try! requestHandler.perform([request], on: image, orientation: orientation)
        return self.rect
    }
}
extension CGRect {
    func scaled(to size: CGSize) -> CGRect {
        return CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: self.size.width * size.width,
            height: self.size.height * size.height
        )
    }
}
extension CGPoint {
    func appleScaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
}
extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
    func anotherScale(to size: CGSize, orientation: UIInterfaceOrientation) -> CGPoint {
        switch orientation {
        case .portrait, .unknown:
            return CGPoint(x: self.y * size.width, y: self.x * size.height)
        case .landscapeLeft:
            return CGPoint(x: (1 - self.x) * size.width, y: self.y * size.height)
        case .landscapeRight:
            return CGPoint(x: self.x * size.width, y: (1 - self.y) * size.height)
        case .portraitUpsideDown:
            return CGPoint(x: (1 - self.y) * size.width, y: (1 - self.x) * size.height)
        }
    }
    func convertFromCamera(view: UIView) -> CGPoint {
        let orientation = UIApplication.shared.statusBarOrientation
        
        switch orientation {
        case .portrait, .unknown:
            return CGPoint(x: self.y * view.frame.width, y: self.x * view.frame.height)
        case .landscapeLeft:
            return CGPoint(x: (1 - self.x) * view.frame.width, y: self.y * view.frame.height)
        case .landscapeRight:
            return CGPoint(x: self.x * view.frame.width, y: (1 - self.y) * view.frame.height)
        case .portraitUpsideDown:
            return CGPoint(x: (1 - self.y) * view.frame.width, y: (1 - self.x) * view.frame.height)
        }
    }
}

//
//  AddShadow.swift
//  Questo
//
//  Created by Taichi Kato on 2/9/17.
//  Copyright © 2017 Questo Inc. All rights reserved.
//

import UIKit
struct UI{
    static func addShadow(view: UIView, color: UIColor = UI.hexStringToUIColor(hex: "#33333"), opacity: Float = 0.2, blur: CGFloat = 4, shouldRasterize: Bool = false){
        //let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)  //Here you control x and y
        view.layer.shadowOpacity = opacity
        view.layer.shadowRadius = blur //Here your control your blur
        view.layer.masksToBounds =  false
//        if (shouldRasterize) {
//            view.layer.rasterizationScale = UIScreen.main.scale
//            view.layer.shouldRasterize = true
//        }
    }
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

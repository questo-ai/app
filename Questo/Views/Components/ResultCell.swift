//
//  ResultCell.swift
//  Questo
//
//  Created by Arya Vohra on 17/10/17.
//  Copyright © 2017 Questo Inc. All rights reserved.
//

import UIKit

class ResultCell: UICollectionViewCell {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var correctnessLabel: UILabel! 
    @IBOutlet weak var correctnessColorView: UIView!
    @IBOutlet weak var correctnessImageView: UIImageView!
    internal var correctness = true {
        didSet {
            if correctness{
                correctnessLabel.text = "Correct"
                correctnessColorView.backgroundColor = UI.hexStringToUIColor(hex: "44C062")
            }else {
                correctnessLabel.text = "Incorrect"
                correctnessColorView.backgroundColor = UI.hexStringToUIColor(hex: "E13156")
            }
        }
    }
    override func awakeFromNib() {
        
    }
}

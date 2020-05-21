//
//  RecentsTableViewCell.swift
//  Questo
//
//  Created by Taichi Kato on 7/5/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import UIKit
protocol RecentsTableViewCellDelegate {
    func practiceTapped(_ row: Int)
}
class RecentsTableViewCell: UITableViewCell {
//    private var fillColor: UIColor = .black // the color applied to the shadowLayer, rather than the view's backgroundColor
    var set: StudySet? {
        didSet {
            let subject = set?.subject ?? "Others"
//            let author = set?.author ?? "you"
//            let date = set?.dateCreated ?? Date()

            if let cards = set?.cards{
                let nCard = cards.count
                var nMastered = 0
                for card in cards {
                    if(card.hasMastered.value ?? false){nMastered += 1}
                }
//                bottomLabel.text = "\(nMastered)/\(nCard) cards mastered"
                progressView.progress = Float(nMastered)/Float(nCard)
            }
            topLabel.text = subject
            mainLabel.text = set?.title ?? "Untitled"
            
        }
    }
    var row: Int!
    var delegate: RecentsTableViewCellDelegate!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var shadowView: ShadowView!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var progressView: HeightProgressView!
    @IBAction func practiceButton(_ sender: Any) {
        delegate.practiceTapped(row)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let radius: CGFloat = 5.0
        cardView.layer.cornerRadius = radius
        cardView.layer.masksToBounds = true
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOpacity = 0.05
        shadowView.layer.shadowRadius = 1
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale



    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class ShadowView: UIView {
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupShadow() {
        self.layer.cornerRadius = 8
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

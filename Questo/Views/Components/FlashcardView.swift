//
//  FlashcardCollectionViewCell.swift
//  Questo
//
//  Created by Taichi Kato on 2/2/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import UIKit

class FlashcardView: UIView {
    class func instanceFromNib() -> FlashcardView {
        return UINib(nibName: "FlashcardView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FlashcardView
    }
    @IBOutlet weak var betaTag: UIImageView!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var flashCard: UIView!
    public var question = "q"
    public var answer = "a"
    var isOpen = false
    @objc func checkAction(sender : UITapGestureRecognizer) {
        flip()
    }
    override func awakeFromNib() {
        UI.addShadow(view: flashCard)
        showBetaTag(false)
    }
    func showBetaTag(_ show: Bool){
        betaTag.isHidden = !show
    }
    func flip(){
        if isOpen{
            isOpen = false
            cardLabel.text = question
            UIView.transition(with: flashCard, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }else{
            isOpen = true
            cardLabel.text = answer
            UIView.transition(with: flashCard, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }
    }
}

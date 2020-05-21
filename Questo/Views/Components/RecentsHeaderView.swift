//
//  RecentsHeaderView.swift
//  Questo
//
//  Created by Taichi Kato on 12/5/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import UIKit

class RecentsHeaderView: UIView {
    let label = UILabel()
    let line = UIView()
    let imageView = UIImageView()
    let subLabel = UILabel()
    let questoButton = QuestoButton(color: .white, text: "Practice", addShadow: false)
    override init(frame: CGRect){
        super.init(frame: frame)
        let view = self
        view.translatesAutoresizingMaskIntoConstraints = false
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        label.text = "Master Set"
        label.textColor = .white
        view.addSubview(label)
        
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        subLabel.textColor = .white
        subLabel.textColor = .white
        subLabel.text = "Need to revise all of your cards at once?"
        subLabel.numberOfLines = -1
        subLabel.textAlignment = .left
        view.addSubview(subLabel)
        
        questoButton.translatesAutoresizingMaskIntoConstraints = false
        questoButton.setTitleColor(.magenta, for: .normal)
        view.addSubview(questoButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "recents-illustration")
        view.addSubview(imageView)
        let constraint = label.topAnchor.constraint(equalTo: view.superview?.topAnchor ?? view.topAnchor, constant: 20)
        constraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            constraint,
            label.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ])
        NSLayoutConstraint.activate([
            subLabel.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 20),
            subLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            subLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
            ])
        NSLayoutConstraint.activate([
            questoButton.topAnchor.constraint(equalTo: subLabel.topAnchor, constant: 80),
            questoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            questoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            questoButton.heightAnchor.constraint(equalToConstant: 40),
            ])
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            imageView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            ])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class QuestoButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    convenience init(radius: CGFloat = 10.0, color: UIColor = .magenta, text: String, addShadow: Bool) {
        self.init()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = radius
        self.backgroundColor = color
        self.setTitle(text, for: .normal)
        self.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14.0)!
        self.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        self.addTarget(self, action: #selector(animateDown), for: .touchDown)
        self.addTarget(self, action: #selector(animateUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(animateUp), for: .touchUpOutside)
        UI.addShadow(view: self)
    }
    @objc private func animateDown() {
        self.animateButtonDown()
        UIView.animate(withDuration: 0.1) {
            self.titleLabel?.alpha = 0.6
        }
    }
    @objc private func animateUp() {
        self.animateButtonUp()
        UIView.animate(withDuration: 0.1) {
            self.titleLabel?.alpha = 1.0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FadingTableView : UITableView {
    var percent = Float(0.05)
    
    fileprivate let outerColor = UIColor(white: 1.0, alpha: 0.0).cgColor
    fileprivate let innerColor = UIColor(white: 1.0, alpha: 1.0).cgColor
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is FadingTableView && keyPath == "bounds" {
            initMask()
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath:"bounds")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateMask()
    }
    
    func initMask() {
        let maskLayer = CAGradientLayer()
        maskLayer.locations = [0.0, NSNumber(value: percent), NSNumber(value:1 - percent), 1.0]
        maskLayer.bounds = CGRect(x:0, y:0, width:frame.size.width, height:frame.size.height)
        maskLayer.anchorPoint = CGPoint.zero
        self.layer.mask = maskLayer
        
        updateMask()
    }
    
    func updateMask() {
        let scrollView : UIScrollView = self
        
        var colors = [AnyObject]()
        
        if scrollView.contentOffset.y <= -scrollView.contentInset.top { // top
            colors = [innerColor, innerColor, innerColor, outerColor];
        }
        else if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height { // bottom
            colors = [outerColor, innerColor, innerColor, innerColor]
        }
        else {
            colors = [outerColor, innerColor, innerColor, outerColor]
        }
        
        if let mask = scrollView.layer.mask as? CAGradientLayer {
            mask.colors = colors
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            mask.position = CGPoint(x: 0.0, y: scrollView.contentOffset.y)
            CATransaction.commit()
        }
    }
}

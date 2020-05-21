//
//  FlashcardSettingViewController.swift
//  Questo
//
//  Created by Taichi Kato on 8/6/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import UIKit


protocol FlashcardSettingDelegate {
    func update(showAll: Bool)
}

class FlashcardSettingViewController: UIViewController {
    var delegate: FlashcardSettingDelegate?
    let label = UILabel()
    var button: QuestoButton!
    var isSRSDisabled = false
    let aSwitch = UISwitch()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        button = QuestoButton(text: "Update Settings", addShadow: false)
        label.text = "Display all cards? (Will temporarily disable spaced interval learning)"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .left
        view.addSubview(label)
        
        aSwitch.setOn(isSRSDisabled, animated: true)
        aSwitch.translatesAutoresizingMaskIntoConstraints = false
        aSwitch.addTarget(self, action: #selector(update), for: .touchUpInside)
        view.addSubview(aSwitch)
        
        button.setTitle("Update Settings", for: .normal)
        button.addTarget(self, action: #selector(update), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            aSwitch.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            aSwitch.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            aSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60)
            ])
        if let button = button {
            view.addSubview(button)
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                button.heightAnchor.constraint(equalToConstant: 36),
                button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
                ])
        }
    }
    override func viewDidAppear(_ animated: Bool) {
    }
    @objc func update(){
        delegate?.update(showAll: aSwitch.isOn)
        self.dismiss(animated: true, completion: nil)
    }
}

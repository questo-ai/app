//
//  WelcomeViewController.swift
//  Questo
//
//  Created by Taichi Kato on 4/6/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    var imageView: UIImageView!
    var welcomeLabel: UILabel!
    var descriptionLabel: UILabel!
    var continueButton: UIButton!
    var avoidButton: UIButton!
    
    var image = UIImage(named: "Welcome")
    var buttonText = "Great, let's go"
    var descriptionText = "Take a quick tour to see how Questo can help you study."
    var titleText = "Welcome!"
    convenience init(image: UIImage?, buttonText: String, descriptionText: String, titleText: String){
        self.init()
        self.image = image
        self.buttonText = buttonText
        self.descriptionText = descriptionText
        self.titleText = titleText
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Logo
        imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: 150),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            ])
        // Button
        continueButton = QuestoButton(color: .magenta, text: buttonText, addShadow: false)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(letsGo), for: .touchUpInside)
        view.addSubview(continueButton)
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            continueButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        // Description
        descriptionLabel = UILabel()
        descriptionLabel.text = descriptionText
        descriptionLabel.numberOfLines = -1
        descriptionLabel.font = .bigText
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .darkGray
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -60),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ])
        // Welcome
        welcomeLabel = UILabel()
        welcomeLabel.text = titleText
        welcomeLabel.font = .title
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(welcomeLabel)
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            welcomeLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -10),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    @objc func letsGo(sender: Any) {
        if(titleText == "Welcome!"){
            let vc = WelcomeViewController(image: UIImage(named: "School"), buttonText: "Create a study set", descriptionText: "Upload your study material to automatically generate a study set.", titleText: "")
            navigationController?.pushViewController(vc, animated: true)
        }else if(titleText == ""){
            let vc = WelcomeViewController(image: UIImage(named: "Rocket"), buttonText: "Got it!", descriptionText: "We suggest you cards to study based on how well you know them.", titleText: "Repetition is Key")
            navigationController?.pushViewController(vc, animated: true)
        }else if(true == false){
            //
        }else{
            //Tutorial Completed
            if let next = UIStoryboard(name: "Camera", bundle: nil).instantiateInitialViewController(){
                next.modalPresentationStyle = .overCurrentContext
                next.modalTransitionStyle = .crossDissolve
                navigationController?.present(next, animated: true)
            }
        }
    }

}

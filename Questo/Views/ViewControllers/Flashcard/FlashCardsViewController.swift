//
//  FlashCardsViewController.swift
//  Questo
//
//  Created by Taichi Kato on 2/2/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import UIKit
import Koloda
import SPAlert
import Lottie
import RealmSwift
import SAConfettiView

class FlashCardsViewController: UIViewController {
    @IBOutlet weak var indicatorText: UILabel!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBAction func reportCardButton(_ sender: Any) {
        reportQuiz(index: self.kolodaView.currentCardIndex)
    }
    var showAll = false
    var cards: List<Card>?
    let realm = try! Realm()
    let backgroundColor: UIColor = UIColor(hue: 0.685, saturation: 0.6, brightness: 1.0, alpha: 1.0)
    var studyset: StudySet?
    var onboardingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        reload()
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        kolodaView.alphaValueSemiTransparent = 0
    }
    @IBOutlet weak var doneButton: UIButton!
    @IBAction func done(_ sender: Any) {
        UIView.animate(withDuration: 0.05) {
            self.kolodaView.alpha = 0.0
        }
        let alert = UIAlertController(title: nil, message: "You have completed \(kolodaView.currentCardIndex) cards!", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { _ in
            if let vc = self.navigationController?.presentingViewController as? BaseViewController, UserDefaults.standard.isFirstLaunch(){
                vc.displayOnboarding = true
            }
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func setupUI(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = UIColor.white
        kolodaView.backgroundColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.0)
        view.backgroundColor = backgroundColor
        showOnboarding()
    }
    func getBackgroundColorForVector(percentage: CGFloat) -> UIColor{
        return UIColor(hue: (-percentage).map(from: -100.0...100.0, to: 0.35...1.0), saturation: 0.6, brightness: 1.0, alpha: 1.0)
    }
    func showOnboarding() {
        //MARK: Onboarding View
           if(UserDefaults.standard.isFirstLaunch()){
                onboardingView = UIView()
               onboardingView.backgroundColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.8)
               view.addSubview(onboardingView)
               
               var onboardingViewFrame = view.frame
               onboardingViewFrame.origin = CGPoint(x: 0.0, y: 0.0)
               onboardingView.frame = onboardingViewFrame
               
               let animationView = AnimationView()
               animationView.animation = Animation.named("animation-w96-h64")
               onboardingView.addSubview(animationView)
               animationView.loopMode = .loop
               animationView.play()
               animationView.translatesAutoresizingMaskIntoConstraints = false
               
               let closeButton = UIButton()
               closeButton.translatesAutoresizingMaskIntoConstraints = false
               closeButton.setTitle("Got it", for: .normal)
               closeButton.layer.cornerRadius = 10
               closeButton.layer.borderColor = UIColor.white.cgColor
               closeButton.layer.borderWidth = 1.0
               closeButton.clipsToBounds = true
               closeButton.titleLabel?.textColor = .white
               closeButton.addTarget(self, action: #selector(animateDown), for: .touchDown)
               closeButton.addTarget(self, action: #selector(animateUp), for: .touchUpInside)
               closeButton.addTarget(self, action: #selector(animateUp), for: .touchUpOutside)
               
               onboardingView.addSubview(closeButton)

               let label = UILabel()
               label.numberOfLines = 5
               label.textAlignment = .center
               label.translatesAutoresizingMaskIntoConstraints = false
               onboardingView.addSubview(label)
               label.text = "Questo uses a spaced repetition system. Swipe left to mark a card as \"Remembered\", \n and right to mark the card as \"Need To Review\""
               label.textColor = .white
               
               NSLayoutConstraint.activate([
                   closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0),
                   closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60.0),
                   closeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
                   label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0),
                   label.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20.0),
                   label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                   animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                   animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                   animationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
               ])
           }
    }
    func reload() {
        if showAll {
            cards = studyset?.cards
        }else {
            cards = studyset?.getCardsForToday()
        }
        kolodaView.reloadData()
    }
    @objc private func animateDown(sender: Any?) {
        if let button = sender as? UIButton {
            button.animateButtonDown()
            UIView.animate(withDuration: 0.1) {
                button.alpha = 0.6
            }
        }
    }
    @objc private func animateUp(sender: Any?) {
        if let button = sender as? UIButton {
            button.animateButtonUp()

            UIView.animate(withDuration: 0.1, animations: {
                button.alpha = 1.0
                self.onboardingView.alpha = 0.0
            }, completion: { (_) in
                self.onboardingView.removeFromSuperview()
            })
        }
    }
    
}
extension FlashCardsViewController: KolodaViewDelegate, KolodaViewDataSource {
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = FlashcardView.instanceFromNib()
        if let cards = cards{
            view.cardLabel.text = cards[index].prompt
            view.isOpen = false
            view.question = cards[index].prompt ?? ""
            view.answer = cards[index].answer ?? ""
        }
        return view
        
    }
    func reportQuiz(index: Int){
        if (cards?.count ?? 0) > index {
            if let cards = cards {
                let card = cards[index]
                kolodaView.swipe(.right)
                try! realm.write {
//                    card.removed = true
                }
                SPAlert.present(title: "Thanks!", message: "We'll make sure you get fewer questions like this.", preset: .done)
                NetworkManager().rateCard(endUrl: "rateCard", id: studyset?.id ?? "", card: card, onCompletion: { (data) in
                },
                                        onError: { (error) in
                                            let alert = UIAlertController(title: "Unable to rate card", message: error.debugDescription, preferredStyle: UIAlertControllerStyle.alert)
                                            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { _ in
                                                self.dismiss(animated: true, completion: nil)
                                                
                                            }))
                                             self.present(alert, animated: true, completion: nil)
                                            print(error.debugDescription)
                })
            }
        } else {
            print("index does not exist")
        }
    }
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return cards?.count ?? 0
    }
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int){
        if let view = koloda.viewForCard(at: index) as? FlashcardView{
            view.flip()
        }
    }
    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {
        var vector = -1
        switch direction{
        case .left:
            indicatorText.text = "I got it!🤘"
            vector = 1
        case .right:
            indicatorText.text = "Need to review"
        default:
            indicatorText.text = ""
        }
        UIView.animate(withDuration: 0.1) {
            // map percentage to text alpha and hue
            self.indicatorText.alpha = CGFloat(finishPercentage/100)
            self.view.backgroundColor = self.getBackgroundColorForVector(percentage: finishPercentage * CGFloat(vector))
        }
    }
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        done(doneButton)
    }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if var currentCard = cards?[index] {
            if (direction == .left) {
                try! realm.write {
                    currentCard = currentCard.rateCard(rating: .good)
                }
                if currentCard.hasMastered.value ?? false {

                }
                print(currentCard.easinessFactor)
            } else if(direction == .right) {
                try! realm.write {
                    currentCard = currentCard.rateCard(rating: .bad)
                }
                print(currentCard.easinessFactor)
            }
        }
    }
    func kolodaPanFinished(_ koloda: KolodaView, card: DraggableCardView) {
        // set everything back to Default state
        UIView.animateKeyframes(withDuration: 0.2, delay: 0.2, options: [], animations: {
            self.indicatorText.alpha = 0.0
            self.view.backgroundColor = self.backgroundColor
        })
        
    }
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return 0.3
    }
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
}

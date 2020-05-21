//
//  DocumentViewController.swift
//  Questo
//
//  Created by Taichi Kato on 31/10/17.
//  Copyright © 2017 Questo Inc. All rights reserved.
//

import UIKit
import Instructions
import Firebase

class DocumentViewController: UIViewController, CoachMarksControllerDataSource, CoachMarksControllerDelegate, BaseViewControllerDelegate{
    var data: [[String:Any]]?
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    let coachMarksController = CoachMarksController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = [
            [
                "body": "Paste in your source text here!",
                "next": "Got it!",
                "view": textArea
            ],[
                "body": "Tap to generate quiz!",
                "next": "Ok!",
                "view": uploadButton
            ]
        ]
        textArea.text = ""
        self.coachMarksController.dataSource = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.coachMarksController.stop(immediately: true)
    }
    @IBAction func upload(_ sender: Any) {
        if textArea.text.count < 51{
            let alert = UIAlertController(title: "Input Sentence Too short",
                                          message: "Our algorithm needs at least 50 characters to work with.",
                                          preferredStyle: .alert)
            let doneAction = UIAlertAction(title:"Got it!", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(doneAction)
            self.present(alert, animated: true, completion:nil)
        }else{
            let vc = EditorViewController()
            vc.text = textArea.text
            self.presentAsStork(vc)
        }
    }
    // MARK: Coach Marks
    func beginCoach() {
            if UserDefaults.standard.isFirstLaunch() {
                self.coachMarksController.start(on: self)
                textArea.text = """
                Questo is an app that helps you retain information and study better, by automatically building study sets for any text.
                
                Questo creates daily "master sets" which contain everything you need to revise, ensuring that you focus on tough content (powered by spaced repetition algorithm). Questo also sorts each set of cards to maximise memory retention.
                
                The first version of Questo was created at a hackathon in Singapore in 2016. In early 2019, the app was named "App of the Day" on ProductHunt.
                """
            }
        }
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        coachViews.bodyView.hintLabel.text = data?[index]["body"] as? String
        coachViews.bodyView.nextLabel.text = data?[index]["next"] as? String
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        if let view = data?[index]["view"] as? UIView{
            return coachMarksController.helper.makeCoachMark(for: view)
        }else{
            return coachMarksController.helper.makeCoachMark(for:view)
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return data?.count ?? 0
    }
    // MARK: Handle Keybaord
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.bottomConstraint?.constant = 40.0
            } else {
                self.bottomConstraint?.constant = (endFrame?.size.height ?? 20.0) + 20.0 
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }


}

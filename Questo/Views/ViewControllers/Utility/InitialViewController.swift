//
//  InitialViewController.swift
//  Questo
//
//  Created by Taichi Kato on 25/8/17.
//  Copyright © 2017 Questo Inc. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import Lottie

class InitialViewController: UIViewController {

    @IBOutlet weak var animationView: AnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        animationView.animation = Animation.named("questo-logo")
        animationView.loopMode = .playOnce
        animationView.play { _ in
            if Auth.auth().currentUser != nil{
                self.performSegue(withIdentifier: "fade", sender: self)
            } else {
                //If not logged in:
                do { try Auth.auth().signOut() } catch {}
                UserDefaults.standard.set(false, forKey: "HasAtLeastLaunchedOnce")
                self.performSegue(withIdentifier: "login", sender: self)
            }
        }
    }
    func registerNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
        let content = UNMutableNotificationContent()
        content.title = "Time to study!"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default()
        
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

}
class Fade: UIStoryboardSegue {
    
    override func perform() {
        
        guard let destinationView = self.destination.view else {
            // Fallback to no fading
            self.source.present(self.destination, animated: false, completion: nil)
            return
        }
        
        destinationView.alpha = 0
        self.source.view?.addSubview(destinationView)
        UIView.setAnimationCurve(.easeInOut)
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            destinationView.alpha = 1
        }, completion: { _ in
            self.source.present(self.destination, animated: false, completion: nil)
        })
    }
}

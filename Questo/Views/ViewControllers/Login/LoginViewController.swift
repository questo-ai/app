
//
//  LoginViewController.swift
//  Questo
//
//  Created by Taichi Kato on 18/2/18.
//  Copyright © 2018 Questo Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    // Or Bar
    @IBOutlet weak var orText: UILabel!
    @IBOutlet weak var orbar: UIView!
    // Constraints
    @IBOutlet weak var tandcTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logInBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var socialLogintoTextConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! //original constant = 52
    // Views
    @IBOutlet var socialButtons: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        //For iPhone SE and lower
        if view.frame.height < 569{
            logInBottomConstraint.constant = 20
            emailTopConstraint.constant = 50
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func facebookButton(_ sender: Any) {
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) in
            if let e = error{
                self.handleError(e)
            }else{
                let fbloginresult : LoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            }
        }
    }
    @IBAction func googleButton(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    @IBAction func loginButton(_ sender: Any) {
        if let email = emailTextField.text, let password  = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if let e = error{
                    self.handleError(e)
                }else{
                    self.performSegue(withIdentifier: "loggedInSegue", sender: self)
                }
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            handleError(error)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        signInWith(credential: credential)
        
    }
    func getFBUserData(){
        if((AccessToken.current) != nil){
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current?.tokenString ?? "")
            signInWith(credential: credential)
        }
    }
    func handleError(_ e: Error) {
        let alert = UIAlertController(title: "Warning",
                                      message: e.localizedDescription,
                                      preferredStyle: .alert)
        let doneAction = UIAlertAction(title:"Got it!", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(doneAction)
        self.present(alert, animated: true, completion:nil)
    }
    func signInWith(credential: AuthCredential){
        Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
            if let e = error{
                self.handleError(e)
            }else{
                self.performSegue(withIdentifier: "loggedInSegue", sender: self)
            }
        }
    }
    
    @objc func keyboardWillHide() {
        self.view.frame.origin.y = 0
        socialLogintoTextConstraint.constant = 34
        bottomConstraint.constant = 60
        tandcTopConstraint.constant = 46
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
            self.socialButtons.alpha = 1
            self.orbar.alpha = 1
            self.orText.alpha = 1
        })
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if emailTextField.isFirstResponder || passwordTextField.isFirstResponder {
                socialLogintoTextConstraint.constant = -120
                bottomConstraint.constant = keyboardSize.height - 28
                tandcTopConstraint.constant = 16
                UIView.animate(withDuration: 0.2, animations: {
                    self.socialButtons.alpha = 0
                    self.orbar.alpha = 0
                    self.orText.alpha = 0
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

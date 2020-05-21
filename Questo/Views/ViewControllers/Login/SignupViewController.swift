//
//  SignupViewController.swift
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

class SignupViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    var displayName = ""

    @IBOutlet weak var socialButtons: UIView!
    @IBOutlet weak var orBar: UIView!
    @IBOutlet weak var orText: UILabel!
    // Text Field
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    // Constraints
    @IBOutlet weak var tandcTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var socialTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameTopConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if view.frame.height < 569{
            bottomConstraint.constant = 10
            socialTopConstraint.constant = 10
            nameTopConstraint.constant = 50
        }
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    

    @objc func keyboardWillHide() {
        self.view.frame.origin.y = 0
        socialTopConstraint.constant = 34
        bottomConstraint.constant = 60
        tandcTopConstraint.constant = 46
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
            self.socialButtons.alpha = 1
            self.orBar.alpha = 1
            self.orText.alpha = 1
        })
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if emailTextField.isFirstResponder || passwordTextField.isFirstResponder || nameTextField.isFirstResponder {
                socialTopConstraint.constant = -120
                bottomConstraint.constant = keyboardSize.height - 28
                tandcTopConstraint.constant = 23
                UIView.animate(withDuration: 0.2, animations: {
                    self.socialButtons.alpha = 0
                    self.orBar.alpha = 0
                    self.orText.alpha = 0
                    self.view.layoutIfNeeded()
                })            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    @IBAction func signUp(_ sender: Any) {
        if let password = passwordTextField.text, let email = emailTextField.text{
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.nameTextField.text
                changeRequest?.commitChanges { (error) in
                    if error != nil{
                        self.handleError(error)
                    }
                }
            }
        }
    }
    @IBAction func facebookButton(_ sender: Any) {
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            } else {
                self.handleError(error)
            }
        }
    }
    internal func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    func getFBUserData(){
        if((AccessToken.current) != nil){
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current?.tokenString ?? "")
            signInWith(credential: credential)
        }
    }
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                       withError error: Error!) {
        if let error = error {
            handleError(error)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        signInWith(credential: credential)
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
    func userSignedIn(user: User!) {
        let ref = Database.database().reference()
        let userInfo: [String : Any] = [
            "name": user.displayName ?? "",
            "email": user.email ?? "",
            "profile": user.photoURL?.absoluteString  ?? ""
            ]
        ref.child("users").child(user.uid).setValue(userInfo)
        displayName = user.displayName ?? "Guest"
        print("User \(displayName) signed in")
        performSegue(withIdentifier: "successSegue", sender: self)
    }
    func handleError(_ error: Error?) {
        if let e = error{
            let alert = UIAlertController(title: "Warning",
                                          message: e.localizedDescription,
                                          preferredStyle: .alert)
            let doneAction = UIAlertAction(title:"Got it!", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(doneAction)
            self.present(alert, animated: true, completion:nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SelectSchoolViewController{
            destination.name = displayName
        }
    }
    
}

//
//  SelectSchoolViewController.swift
//  Questo
//
//  Created by Taichi Kato on 21/3/18.
//  Copyright © 2018 Questo Inc. All rights reserved.
//

import UIKit
import Firebase

class SelectSchoolViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var topLabelConstraint: NSLayoutConstraint!
    var name: String?
    var school: String?
    var schools = kSchools
    @IBOutlet weak var schoolPicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schools.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return schools[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        ref.child("users").child(userID).child("school").setValue(schools[row])
        print("\(name) goes to \(schools[row])")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LoginSuccessViewController{
            destination.name = self.name!
            let ref = Database.database().reference()
            ref.child("users").childByAutoId().child("school").setValue(school)
            print("\(name) goes to \(school)")

        }
    }
    
}

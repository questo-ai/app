//
//  LoginSuccessViewController.swift
//  Questo
//
//  Created by Taichi Kato on 19/2/18.
//  Copyright © 2018 Questo Inc. All rights reserved.
//

import UIKit

class LoginSuccessViewController: UIViewController {
    var name = ""
    @IBOutlet weak var successLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        successLabel.text = "Welcome to questo!" + name
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

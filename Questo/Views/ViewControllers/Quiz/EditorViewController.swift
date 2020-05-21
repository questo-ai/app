//
//  EditorViewController.swift
//  Questo
//
//  Created by Taichi Kato on 9/5/19.
//  Copyright © 2019 Questo Inc. All rights reserved.
//

import UIKit
import Eureka
import SwiftyJSON
class EditorViewController: FormViewController {
    var text: String?
    var images: [UIImage]?
    override func viewDidLoad() {
        super.viewDidLoad()
        let font =  UIFont.systemFont(ofSize: 14, weight: .bold)
        tableView.contentInset.top = 60
        let type = "Create New Set"
        form +++
            Section() {
                var header = HeaderFooterView<CreateFormHeaderView>(.nibFile(name: "CreateFormHeaderView", bundle: nil))
                header.onSetupView = { (view, section) -> () in
                    view.topLabel.text = type
                }
                header.height = { UITableViewAutomaticDimension + 40 }
                $0.header = header

            }
            +++  Section()
                <<< PickerInputRow<String>("subject"){
                    $0.title = "Subject"
                    $0.options = ["Philosophy", "Literature", "Business", "Physics", "Chemistry", "Biology", "History", "Economics", "Psychology", "Computer Science", "Others"]
                    $0.value = $0.options.last
                }.cellSetup { cell, row in
                    cell.textLabel?.font = font
                    cell.tintColor = .magenta
                    cell.detailTextLabel?.font = font
                }
            
            <<< NameRow("title") {
                    $0.title = "Set Name"
                    $0.placeholder = "Untitled Set"
                }.cellSetup { cell, row in
                    cell.textLabel?.font = font
                    cell.textField?.font = font
                    cell.detailTextLabel?.font = font
                    cell.tintColor = .magenta
                }
            
//                <<< IntRow("maxNum") {
//                    $0.title = "Max number of cards"
//                    $0.value = 20
//                }.cellSetup { cell, row in
//                    cell.textLabel?.font = font
//                    cell.textField?.font = font
//                    cell.detailTextLabel?.font = font
//                    cell.tintColor = .magenta
//                }
//
//                <<< CheckRow("beta") {
//                    $0.title = "Enable Beta Features"
//                    $0.value = true
//                }.cellSetup { cell, row in
//                    cell.textLabel?.font = font
//                    cell.detailTextLabel?.font = font
//                    cell.tintColor = .magenta
//                }
//        +++  Section() {
//            var header = HeaderFooterView<AdditionalSourceView>(.nibFile(name: "AdditionalSourceView", bundle: nil))
//            header.onSetupView = { (view, section) -> () in
//                
//            }
//            $0.header = header
//        }
//            <<< URLRow("extraUrl") {
//                $0.value = URL(string: "http://questo.ai")
//                }.cellSetup { cell, row in
//                    cell.textLabel?.font = font
//                    cell.detailTextLabel?.font = font
//                    cell.tintColor = .magenta
//            }
//            
        +++  Section() {
            var footer = HeaderFooterView<ButtonView>(.class)
            footer.onSetupView = { (view, section) -> () in
                view.button.addTarget(self, action: #selector(self.upload), for: .touchUpInside)
            }
            footer.height = { UITableViewAutomaticDimension + 40 }
            $0.footer = footer
                
        }
        // Remove excess separator lines on non-existent cells
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundView = UIView()
        tableView.backgroundColor = UIColor.white
    }
    @objc func upload() {
        let valuesDictionary = form.values()
        let parameters = valuesDictionary.compactMapValues { $0 }
        if let nc = UIStoryboard(name: "Flashcard", bundle: nil).instantiateInitialViewController() as? UINavigationController, let vc = nc.topViewController as? OverviewTableViewController {
            vc.newQuiz = true
            if let title = parameters["title"] as? String{
                vc.quizTitleText = title
            }
            vc.parameters = parameters
            if let text = text{
                vc.text = text
            }else if let images = images{
                vc.images = images
            }
            weak var parent = self.presentingViewController
            self.dismiss(animated: true) {
                nc.modalPresentationStyle = .overCurrentContext
                parent?.present(nc, animated: true, completion: {
                    
                })
            }
        }
    }
}

class CreateFormHeaderView: UIView {
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
class AdditionalSourceView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ButtonView: UIView {
    
    var button: UIButton!
    var label: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        button = QuestoButton(text: "Create New Quiz", addShadow: false)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        
        label = UILabel()
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 10)
        label.textColor = .darkGray
        label.text = "Powered by Questo AI"
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

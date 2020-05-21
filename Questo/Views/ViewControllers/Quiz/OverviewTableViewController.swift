//
//  OverviewTableViewController.swift
//  Questo
//
//  Created by Taichi Kato on 2/9/17.
//  Copyright © 2017 Questo Inc. All rights reserved.
//

import RealmSwift
import UIKit
import SwiftyJSON
import SPStorkController

class OverviewTableViewController: UITableViewController, FlashcardSettingDelegate {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startText: UILabel!
    var manager: NetworkManager!
    var isMutable = true
    var text: String?
    var quizTitleText: String?
    var parameters: [String:Any] = [:]
    var studyset: StudySet?
    var images: [UIImage]?
    var loadingView: LoadingView!
    var newQuiz = false
    func update(showAll: Bool) {
        self.showAll = showAll
    }
    var showAll = false {
        didSet {
            reload()
        }
    }
    var cards: List<Card>?
    @IBOutlet weak var quizTitle: UILabel!
    @IBOutlet weak var pen: UIButton!
    @IBOutlet weak var quizCountLabel: UILabel!
    @IBOutlet weak var edit: UIButton!
    @IBAction func startButton(_ sender: Any) {
        performSegue(withIdentifier: "startQuiz", sender: nil)
    }
    @IBAction func editButton(_ sender: Any) {
        let controller = FlashcardSettingViewController()
        controller.delegate = self
        controller.aSwitch.setOn(showAll, animated: false)
        controller.isSRSDisabled = showAll
        let transitionDelegate = SPStorkTransitioningDelegate()
        controller.transitioningDelegate = transitionDelegate
        transitionDelegate.customHeight = UIScreen.main.bounds.height / 2
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func edit(_ sender: Any) {
        var inputTextField: UITextField?
        inputTextField?.text = self.quizTitle.text
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Rename quiz", message: "", preferredStyle: .alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        //Create and an option action
        let nextAction: UIAlertAction = UIAlertAction(title: "Rename!", style: .default) { action -> Void in
            self.quizTitle.text = inputTextField?.text
            let realm = try! Realm()
            try! realm.write {
                self.studyset?.title = inputTextField?.text
            }
        }
        actionSheetController.addAction(nextAction)
        //Add a text field
        actionSheetController.addTextField { textField -> Void in
            // you can use this text field
            inputTextField = textField
        }
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        manager = NetworkManager()
        if let text = quizTitleText{
            quizTitle.text = text
        }
        let nib = UINib(nibName: "PreviewTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PreviewTableViewCell")
        if newQuiz{
            self.loadingView = UINib(nibName: "LoadingView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? LoadingView
            self.loadingView.closeButton.addTarget(self, action: #selector(dismiss(_:)), for: .touchUpInside)
            self.loadingView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            if let l = self.loadingView{
                self.navigationController?.view.addSubview(l)
            }
            makeRequest()
        }else{
            reload()
        }
        if let _ = self.presentingViewController as? BaseViewController {
            
        }
    }
    func save(studyset: StudySet){
        let realm = try! Realm()
        try! realm.write {
            studyset.dateCreated = Date()
            realm.add(studyset)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = UIColor.vibrantBlue
        reload()
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    private func setupUI() {
        if !isMutable {
            pen.isHidden = true
        }
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.vibrantBlue
        quizTitle.text = studyset?.title ?? "Untitled Quiz"
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.isScrollEnabled = true
        tableView.estimatedRowHeight = 50
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewTableViewCell", for: indexPath) as! PreviewTableViewCell
        cell.term.text = cards?[indexPath.row].prompt
        cell.answer.text = cards?[indexPath.row].answer
        return cell
    }
    
    @IBAction func dismiss(_ sender: Any) {
        if let base = self.presentingViewController as? BaseViewController{
            base.dismiss(animated: true, completion: nil)
        }else {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FlashCardsViewController{
            if let set = studyset{
                vc.studyset = set
                vc.showAll = showAll
            }else{
                return
            }
        }
    }
    func reload() {
        if(showAll){
            cards = studyset?.cards
            quizCountLabel.text = "Showing all \(String(studyset?.cards.count ?? 0)) cards"
        }else{
            cards = studyset?.getCardsForToday()
            quizCountLabel.text = "\(String(cards?.count ?? 0)) / \(String(studyset?.cards.count ?? 0)) cards due today"
        }
        if(cards?.isEmpty ?? true){
            startButton.tintColor = .darkGray
            startButton.isEnabled = false
            quizCountLabel.text = "No cards due today"
            let view = EmptyStateView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2))
            view.label.text = "All completed! Come back tomorrow :)"
            view.subLabel.text =  "You have completed all cards in this set which are due today."
            tableView.tableFooterView = view
        }else{
            startButton.tintColor = .clear
            startButton.isEnabled = true
            tableView.tableFooterView = UIView()
        }
        tableView.reloadData()
    }
    func makeRequest() {
        self.parameters["beta"] = "false"
        print(String(images?.count ?? 0), " images")
        if let images = images{
            let context = CIContext.init(options: nil)
            let imagesData = images.map { (image) -> Data? in
                if let ciimage = image.ciImage{
                    let cgImage = context.createCGImage(ciimage, from: ciimage.extent)!
                    return UIImageJPEGRepresentation(UIImage(cgImage: cgImage), 0.8)
                }
                return nil
            }
            manager.requestWith(endUrl: "generate/image", imageData: imagesData, parameters: parameters, onCompletion: completedRequest) { (error) in
                let alert = UIAlertController(title: "Unable to generate quiz", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                self.present(alert, animated: true, completion: nil)
                print(error.debugDescription)
            }
        }
        else if let text = text{
            manager.requestWith(endUrl: "generate/text", documentData: text, parameters: parameters, onCompletion: completedRequest) { (error) in
                let alert = UIAlertController(title: "Unable to generate quiz", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                self.present(alert, animated: true, completion: nil)
                print(error.debugDescription)
            }
        }
    }
    func completedRequest(_ response: JSON?){
        let dict = response?.dictionaryObject
        if let set = StudySet(JSON: dict ?? ["":""]), set.cards.count > 0{
            self.studyset = set
            set.title = quizTitleText
            self.save(studyset: set)
            self.reload()
            UIView.transition(with: self.view, duration: 0.1, options: [.transitionCrossDissolve], animations: {
                self.loadingView.removeFromSuperview()
            }, completion: { _ in
            })
            
        }else{
            let alert = UIAlertController(title: "No Quiz Generated", message: "We weren't able to generate any quiz from your photo. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

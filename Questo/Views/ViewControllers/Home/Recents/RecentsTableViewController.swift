//
//  RecentsTableViewController.swift
//  Questo
//
//  Created by Taichi Kato on 10/9/17.
//  Copyright © 2017 Questo Inc. All rights reserved.
//

import RealmSwift
import UIKit
import SPStorkController

class RecentsTableViewController: UITableViewController, RecentsTableViewCellDelegate {
    var sets: Results<StudySet>!
    var isMutable = true
    var header: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        sets = realm.objects(StudySet.self).sorted(byKeyPath: "dateCreated", ascending: false)
        setupUI()
        let nib = UINib(nibName: "RecentsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "RecentsTableViewCell")
//        empty(sets.isEmpty)

    }
    func setupUI() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        self.tableView.backgroundView = backgroundView
        addNavigationBar()
        
        let recents = RecentsHeaderView()
        recents.backgroundColor = .magenta
        recents.layer.cornerRadius = 5
        recents.clipsToBounds = true
        recents.questoButton.addTarget(self, action: #selector(practiceMaster), for: .touchUpInside)

        header = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 220))
        header.addSubview(recents)
        self.tableView.sectionHeaderHeight = 200
        self.tableView.tableHeaderView = header

        NSLayoutConstraint.activate([
            recents.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            recents.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            recents.topAnchor.constraint(equalTo: header.topAnchor, constant: 10),
            recents.heightAnchor.constraint(equalToConstant: 200)
            ])
        let footer = FooterView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/6))
        footer.button.addTarget(self, action: #selector(createSet), for: .touchUpInside)
        tableView.tableFooterView = footer
    }

    private func addNavigationBar(){
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 75))
        titleLabel.text = "Questo"
        titleLabel.textColor = .magenta
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Shape"), style: .plain, target: self, action: #selector(createSet))
//        self.navigationItem.rightBarButtonItem?.tintColor = .lightGray
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Feedback", style: .plain, target: self, action: #selector(openFeedback))
        self.navigationItem.titleView = titleLabel
    }
    @objc func openFeedback(){
        if let url = URL(string: "http://bit.ly/questo-feedback") {
            UIApplication.shared.open(url)
        }
    }
    @objc func createSet(){
        if let vc = self.parent as? BaseViewController{
            vc.scrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.width, y: 0), animated: true)
        }
    }
    @objc func practiceMaster(){
        if let nc = UIStoryboard(name: "Flashcard", bundle: nil).instantiateInitialViewController() as? UINavigationController, let vc = nc.topViewController as? OverviewTableViewController{
            let realm = try! Realm()
            try! realm.write() {
                vc.isMutable = false
                vc.studyset = SM2Engine.masterSet()
            }
            nc.modalPresentationStyle = .overFullScreen
            self.present(nc, animated: true, completion: {
                print("presented")
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    func empty(_ empty: Bool){
        if empty {
            let view = EmptyStateView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height*2/5, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*3/5))
            tableView.tableFooterView = view
            
        }else{
            tableView.tableFooterView = nil
        }
    }
    @IBOutlet weak var noQuiz: UIView!

    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        empty(sets.isEmpty)
    }
    @objc func reload(_ sender: Any){
        tableView.reloadData()
        empty(sets.isEmpty)
        tableView.refreshControl?.endRefreshing()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentsTableViewCell", for: indexPath) as! RecentsTableViewCell
        cell.backgroundColor = .white
        cell.set = sets[indexPath.row]
        cell.delegate = self
        cell.row = indexPath.row
        return cell
    }
    func practiceTapped(_ row: Int) {
        isMutable =  true
        if let nc = UIStoryboard(name: "Flashcard", bundle: nil).instantiateInitialViewController() as? UINavigationController, let vc = nc.topViewController as? OverviewTableViewController {
            vc.newQuiz = false
            vc.isMutable = isMutable
            vc.studyset = sets[row]
            nc.modalPresentationStyle = .overFullScreen
            self.present(nc, animated: true) {
                print("presented")
            }
        }
    }
}
class FooterView: UIView {
    let button = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "plus"), for: .normal)
        button.setTitle("Create Set", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 12
        button.backgroundColor = .darkGray
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        self.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class EmptyStateView: UIView {
    let imageView = UIImageView(image: UIImage(named: "undraw_reading_0re1"))
    let label = UILabel()
    let subLabel = UILabel()
    override init(frame: CGRect){
        super.init(frame: frame)
        let view = self
        imageView.frame = CGRect.zero
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "No study set"
        view.addSubview(label)
        
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.font = UIFont.systemFont(ofSize: 14)
        subLabel.textColor = .darkGray
        subLabel.text = "Begin by scanning a text or creating a study set"
        subLabel.numberOfLines = 0
        subLabel.textAlignment = .center
        
        view.addSubview(subLabel)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/3),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -UIScreen.main.bounds.height/6),
            ])
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            ])
        NSLayoutConstraint.activate([
            subLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            subLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 

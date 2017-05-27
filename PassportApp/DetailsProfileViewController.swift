//
//  DetailsProfileViewController.swift
//  PassportApp
//
//  Created by Idelfonso Gutierrez Jr. on 5/27/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import UIKit

class DetailsProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    var profile: Profile?
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var sexSwitch: UISegmentedControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var hobbiesTableView: UITableView!
    
    // MARK: - App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hobbiesTableView.delegate = self
        self.hobbiesTableView.dataSource = self
        setupNavBar()
    }

    // MARK: - View Controller
    func setupNavBar() {
        let saveButton = UIBarButtonItem(title: "save", style: .done, target: self, action: #selector(saveProfileInfo))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    func saveProfileInfo() {
        //TODO: Update user in Firebase
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: show
    }

}

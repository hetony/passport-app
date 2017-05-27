//
//  UserListTableViewController.swift
//  PassportApp
//
//  Created by Idelfonso Gutierrez Jr. on 5/27/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import UIKit
import Firebase

class UserListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    var ref: FIRDatabaseReference!
    fileprivate var _refHandle: FIRDatabaseHandle!
    var profilesSnapshortArray: [FIRDataSnapshot]! = []
    var profileArray: [Profile]?
    var storageRef: FIRStorageReference!

    // MARK: - IBOutlets
    @IBOutlet weak var usersTableView: UITableView!
    
    // MARK: - App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usersTableView.delegate = self
        self.usersTableView.dataSource = self
        configureDatabase()
        configureStorage()
        setupNavBar()
    }


    // MARK: - View Controller Functions
    func setupNavBar() {
        self.navigationItem.title = "Passport Inc"
        
        let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilterView))
        self.navigationItem.leftBarButtonItem = filterButton
        
        let addProfile = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewProfile))
        self.navigationItem.rightBarButtonItem = addProfile
    }
    
    func addNewProfile() {
        let newProfileController = storyboard?.instantiateViewController(withIdentifier: "DetailsProfileViewController") as! DetailsProfileViewController
        self.navigationController?.pushViewController(newProfileController, animated: true)
    }
    
    func showFilterView() {
        //TODO: Show overlay
    }
    
    
    // MARK: - Firebase
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        _refHandle = ref.child("profile").observe(.childAdded, with: { (snapshot) in
            self.profilesSnapshortArray.append(snapshot)
            let student = Profile.loadStudentFromDictionary(snapshot.value as! [String: Any])
            self.profileArray?.append(student)
        })
        
        _refHandle = ref.child("profile").observe(.childChanged, with: { (updateSnapshot) in
            //TODO: look for key matching IDs
            //TODO: compare childs
            //TODO: Change values
        })
    }
    
    func configureStorage() {
        storageRef = FIRStorage.storage().reference()
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
        
        if profileArray != nil {
            cell.textLabel?.text = profileArray![indexPath.row].name
            cell.detailTextLabel?.text = "\(profileArray![indexPath.row].age!)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsController = storyboard?.instantiateViewController(withIdentifier: "DetailsProfileViewController") as! DetailsProfileViewController
        detailsController.profile = self.profileArray?[indexPath.row]
        self.present(detailsController, animated: true, completion: nil)
    }
    
}

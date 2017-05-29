//
//  UserListTableViewController.swift
//  PassportApp
//
//  Created by Idelfonso Gutierrez Jr. on 5/27/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import UIKit
import Firebase

class UserListTableViewController: UIViewController {

    // MARK: Singleton
    var app = FirebaseUserManager.sharedInstance
    
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
        app.configureDatabase()
        app.configureStorage()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ref.removeObserver(withHandle: _refHandle)
    }

    // MARK: - View Controller Functions
    func setupNavBar() {
        self.navigationItem.title = "Passport Inc"
        
        let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilterView))
        self.navigationItem.leftBarButtonItem = filterButton
        
        let addProfile = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewProfile))
        self.navigationItem.rightBarButtonItem = addProfile
    }
    
    func registerObservers() {
        app.refHandle = app.ref.child("profile").observe(.childAdded, with: { (snapshot) in
            print(snapshot.value)
            self.profilesSnapshortArray.append(snapshot)
            let student = Profile.loadStudentFromDictionary(snapshot.value as! [String: Any])
            self.profileArray?.append(student)
        })
        
        app.refHandle = app.ref.child("profile").observe(.childChanged, with: { (updateSnapshot) in
            //TODO: look for key matching IDs
            var updatedUser = updateSnapshot.value as! [String: Any]
            print(updatedUser)
            //TODO: compare childs
            //TODO: Change values
        })
    }
    
    func addNewProfile() {
        //TODO: erase this
        let data: [String: Any] = [
            "name": "Idelfonso",
            "age": 22,
            "sex": "M"
        ]
        
        ref.child("profiles").childByAutoId().setValue(data)
        
        //TODO: Dont erase this
//        let newProfileController = storyboard?.instantiateViewController(withIdentifier: "DetailsProfileViewController") as! DetailsProfileViewController
//        newProfileController.newUser = true
//        self.navigationController?.pushViewController(newProfileController, animated: true)
    }
    
    func showFilterView() {
        //TODO: Show overlay
    }
    
}

// MARK: -
extension UserListTableViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.profileArray?.count)!
    }
    
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
        detailsController.newUser = false
        self.present(detailsController, animated: true, completion: nil)
    }
}

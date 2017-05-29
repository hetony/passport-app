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

    // MARK: Singleton
    var app = FirebaseUserManager.sharedInstance
    
    // MARK: - Properties
    var profiles: [Profile]? = PAData.shared().users

    // MARK: - IBOutlets
    @IBOutlet weak var usersTableView: UITableView!
    
    // MARK: - App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usersTableView.delegate = self
        self.usersTableView.dataSource = self
        
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        app.ref.removeObserver(withHandle: app.refHandle)
    }

    // MARK: - View Controller Functions
    func setupNavBar() {
        self.navigationItem.title = "Passport Inc"
        
        let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilterView))
        self.navigationItem.leftBarButtonItem = filterButton
        
        let addProfile = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewProfile))
        self.navigationItem.rightBarButtonItem = addProfile
    }
    
//    func registerFirebaseObservers() {
//        app.refHandle = app.ref.child(Path.Profiles).observe(.childAdded, with: { (snapshot) in
//            print(snapshot.value)
//            self.profilesSnapshortArray.append(snapshot)
//            let student = Profile.loadStudentFromDictionary(snapshot.value as! [String: Any])
//            self.profileArray?.append(student)
//        })
//        
//        app.refHandle = app.ref.child(Path.Profiles).observe(.childChanged, with: { (updateSnapshot) in
//            //TODO: look for key matching IDs
//            var updatedUser = updateSnapshot.value as! [String: Any]
//            print(updatedUser)
//            //TODO: compare childs
//            //TODO: Change values
//        })
//    }
    
    func addNewProfile() {
        let newProfileController = storyboard?.instantiateViewController(withIdentifier: "DetailsProfileViewController") as! DetailsProfileViewController
        newProfileController.newUser = true
        self.navigationController?.pushViewController(newProfileController, animated: true)
    }
    
    func showFilterView() {
        //TODO: Show overlay
    }
    
    //MARK: - UITableViewDelegate DataSources
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.profiles?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath)
        
        if profiles != nil {
            cell.textLabel?.text = profiles![indexPath.row].name
            cell.detailTextLabel?.text = "\(profiles![indexPath.row].age!)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsController = storyboard?.instantiateViewController(withIdentifier: "DetailsProfileViewController") as! DetailsProfileViewController
        detailsController.profile = self.profiles?[indexPath.row]
        detailsController.newUser = false
        self.present(detailsController, animated: true, completion: nil)
    }
}

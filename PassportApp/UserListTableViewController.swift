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
    var firebaseApp = FirebaseUserManager.sharedInstance
    var passportApp = PAData.sharedInstance

    // MARK: - IBOutlets
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var screenSaver: UIView!
    @IBOutlet weak var passportTitleLabel: UILabel!
    
    
    // MARK: - App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        self.passportApp.users = []
        firebaseApp.configureDatabase()
        firebaseApp.configureStorage()
        loadFirebaseData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.screenSaver.isHidden = false
        let indicator = startActivityIndicatorAnimation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.usersTableView.reloadData()
            self.screenSaver.isHidden = true
            self.stopActivityIndicatorAnimation(indicator: indicator)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    // MARK: - UserListTable View Controller Functions
    func setupNavBar() {
        self.navigationItem.title = "Passport Inc"
        
        let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilterView))
        self.navigationItem.leftBarButtonItem = filterButton
        
        let addProfile = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewProfile))
        self.navigationItem.rightBarButtonItem = addProfile
    }
    
    func loadFirebaseData() {
        firebaseApp.registerUserAddedObserver { (dictionary) in
            let user = Profile.loadStudentFromDictionary(dictionary)
            self.passportApp.users?.append(user)
        }
    }

    
    func getNextIDNumber() -> Int {
        //Assuming that there is a full array an int value will be retrieve
        if self.passportApp.users?.count == 0 {
            return 0
        }
        
        if self.passportApp.users?.count == 1 {
            return 1
        } else {
            return (self.passportApp.users?[(self.passportApp.users?.count)! - 1].id)!
        }
    }
    
    
    // MARK: - Actions
    func addNewProfile() {
        let newProfileController = storyboard?.instantiateViewController(withIdentifier: "DetailsProfileViewController") as! DetailsProfileViewController
        let newId = getNextIDNumber()
        let newProfile = Profile(id: newId, name: nil, age: nil, sex: nil, hobbies: nil, newUser: true)
        newProfileController.profile = newProfile
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
        if let count = self.passportApp.users?.count {
            return count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath)
        
        //FIXME: checking for empty array
        // this is caught when it first retrieves DB with no users in the introViewController
        if passportApp.users != nil {
            cell.textLabel?.text = passportApp.users![indexPath.row].name
            cell.detailTextLabel?.text = "\(passportApp.users![indexPath.row].age!)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsController = storyboard?.instantiateViewController(withIdentifier: "DetailsProfileViewController") as! DetailsProfileViewController
        detailsController.profile = self.passportApp.users?[indexPath.row]
        self.navigationController?.pushViewController(detailsController, animated: true)
    }
}

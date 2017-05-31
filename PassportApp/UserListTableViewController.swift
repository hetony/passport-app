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
        performAnimationAndDataLoad()
    }
    

    // MARK: - UserListTable View Controller Functions
    func setupNavBar() {
        self.navigationItem.title = "Passport Inc"
        
        let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilterView))
        self.navigationItem.leftBarButtonItem = filterButton
        
        let addProfile = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewProfile))
        self.navigationItem.rightBarButtonItem = addProfile
    }
    
    /*Loading Acitvity*/
    func performAnimationAndDataLoad() {
        self.screenSaver.isHidden = false
        let indicator = startActivityIndicatorAnimation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.usersTableView.reloadData()
            self.screenSaver.isHidden = true
            self.stopActivityIndicatorAnimation(indicator: indicator)
        }
    }
    
    /* Use RegisterUser Observer*/
    func loadFirebaseData() {
        var updateUser: Profile?
        
        firebaseApp.registerUserAddedObserver { (dictionary, childKey) in
            let user = Profile.loadStudentFromDictionary(dictionary, childKey: childKey)
            self.passportApp.users?.append(user)
        }
        
        firebaseApp.registerUserUpdatedObserver { (dictionary) in
            print("Update User")
            updateUser = Profile.loadStudentFromDictionary(dictionary, childKey: nil)
            self.replaceUser(updateUser!)
        }
    }

    /* Replace the updateUser in the passportApp user by id*/
    func replaceUser(_ updatedUser: Profile) {
        for user in passportApp.users! {
            if updatedUser == user {
                let index = passportApp.users?.index(of: user)
                print(index)
            }
        }
    }
    
    /* Set userID*/
    func getNextIDNumber() -> Int {
        guard let arrCount = self.passportApp.users?.count else {
            return 0
        }
        
        if arrCount - 1 == 0 {
            return 0
        }
        
        if arrCount == 1 {
            return 1
        } else {
            return (arrCount + 1)
        }
    }
    
    
    // MARK: - Actions
    func addNewProfile() {
        let newProfileController = storyboard?.instantiateViewController(withIdentifier: "DetailsProfileViewController") as! DetailsProfileViewController
        let newId = getNextIDNumber()
        let newProfile = Profile(id: newId, name: nil, age: nil, sex: nil, hobbies: nil, newUser: true, imageUrl: nil, pushId: nil)
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
        cell.textLabel?.text = passportApp.users![indexPath.row].name
        cell.detailTextLabel?.text = "\(passportApp.users![indexPath.row].age!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsController = storyboard?.instantiateViewController(withIdentifier: "DetailsProfileViewController") as! DetailsProfileViewController
        detailsController.profile = self.passportApp.users?[indexPath.row]
        self.navigationController?.pushViewController(detailsController, animated: true)
    }
}

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

    // MARK: - Properties
    var temp: [Profile]?
    
    // MARK: - IBOutlets
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var screenSaver: UIView!
    @IBOutlet weak var passportTitleLabel: UILabel!
    @IBOutlet var searchView: UIView!
    
    @IBOutlet weak var ascDescControl: UISegmentedControl!
    @IBOutlet weak var nameAgeSegmentControl: UISegmentedControl!
    @IBOutlet weak var genderSegementControll: UISegmentedControl!
    
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
    
    /* Firebase Observers*/
    func loadFirebaseData() {
        var updateUser: Profile?
        
        //New User
        firebaseApp.registerUserAddedObserver { (dictionary, childKey) in
            let user = Profile.loadStudentFromDictionary(dictionary, childKey: childKey)
            self.passportApp.users?.append(user)
        }
        
        //Updated User
        firebaseApp.registerUserUpdatedObserver { (dictionary) in
            updateUser = Profile.loadStudentFromDictionary(dictionary, childKey: nil)
            self.replaceUser(updateUser!)
        }
    }

    /* Replace the updateUser in the passportApp user by id*/
    func replaceUser(_ updatedUser: Profile) {
        for user in passportApp.users! {
            if updatedUser == user {
                let index = passportApp.users?.index(of: user)
                self.passportApp.users?[index!] = updatedUser
            }
        }
    }
    
    /* Set userID*/
    func getNextIDNumber() -> Int {
        guard let arrCount = self.passportApp.users?.count else {
            return 0
        }
        
        if arrCount == 0 {
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
    
    // MARK: - Search View
    func showFilterView() {
        searchView.center = self.view.center
        self.view.addSubview(searchView)
    }
    
    @IBAction func clearFilterButton(_ sender: UIButton) {
        //TODO: clear all settings
        self.searchView.removeFromSuperview()
    }
    
    @IBAction func filterButton(_ sender: UIButton) {
        //TODO: satisifes all filters
        orderByNameAgeAscendingDescending()
        //orderByGender()
        self.searchView.removeFromSuperview()
    }
    
    @IBAction func closeFilterWindow(_ sender: UIButton) {
        self.searchView.removeFromSuperview()
    }
    
    
    func orderByNameAgeAscendingDescending() {
        switch (self.nameAgeSegmentControl.selectedSegmentIndex, self.ascDescControl.selectedSegmentIndex) {
            //NAME  = 0
            //AGE   = 1
            //ASC   = 0
            //DESC  = 1
            
        case (0, 0): // (Name || Age, ascending || Desc)
            let sortByName = self.passportApp.users?.sorted(by: { (a, b) -> Bool in
                a.name! < b.name!
            })
            
            self.temp = self.passportApp.users
            self.passportApp.users?.removeAll(keepingCapacity: false)
            self.passportApp.users = sortByName
            break
        case (0, 1):
            let sortByName = self.passportApp.users?.sorted(by: { (a, b) -> Bool in
                a.name! > b.name!
            })
            
            self.temp = self.passportApp.users
            self.passportApp.users?.removeAll(keepingCapacity: false)
            self.passportApp.users = sortByName
            break
        case (1, 0):
            let sortByName = self.passportApp.users?.sorted(by: { (a, b) -> Bool in
                a.age! < b.age!
            })
            
            self.temp = self.passportApp.users
            self.passportApp.users?.removeAll(keepingCapacity: false)
            self.passportApp.users = sortByName
            break
        case (1, 1):
            let sortByName = self.passportApp.users?.sorted(by: { (a, b) -> Bool in
                a.age! > b.age!
            })
            
            self.temp = self.passportApp.users
            self.passportApp.users?.removeAll(keepingCapacity: false)
            self.passportApp.users = sortByName
            break
        default:
            //todo:
            break
        }
        self.usersTableView.reloadData()
        UserDefaults.standard.set(true, forKey: kDataFiltered)
    }
    
    func orderByGender() {
        switch self.genderSegementControll.selectedSegmentIndex {
        case 0:
            break
        case 1:
            break
        default:
            break
        }
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

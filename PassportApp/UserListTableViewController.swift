//
//  UserListTableViewController.swift
//  PassportApp
//
//  Created by Idelfonso Gutierrez Jr. on 5/27/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

enum Gender: Int {
    case Male = 0, Female
}

enum CompassPoint: Int {
    case North = 100, South, East, West
}

enum Order: Int {
    case Ascending = 0, Descending
}

enum Param: Int {
    case Name = 0, Age
}

class UserListTableViewController: UIViewController, NVActivityIndicatorViewable, UITableViewDelegate, UITableViewDataSource {

    // MARK: Singleton
    var firebaseApp = FirebaseUserManager.sharedInstance
    var passportApp = PAData.sharedInstance

    // MARK: - Properties
    var original: [Profile]? //Make a copy before sorting
    
    // MARK: - IBOutlets
    @IBOutlet weak var usersTableView: UITableView!
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
    
    /*Loading Activity*/
    func performAnimationAndDataLoad() {
        let size = CGSize(width: 40, height: 40)
        startAnimating(size, message: "Loading")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.usersTableView.reloadData()
            self.stopAnimating()
        }
    }
    
    /* Firebase Observers*/
    func loadFirebaseData() {
        //var updateUser: Profile? TEST
        
        //New User
        firebaseApp.registerUserAddedObserver { (dictionary, childKey) in
            let user = Profile.loadStudentFromDictionary(dictionary, childKey: childKey)
            self.passportApp.users?.append(user)
        }
        
        //Updated User
        firebaseApp.registerUserUpdatedObserver { (dictionary) in
            var updateUser = Profile.loadStudentFromDictionary(dictionary, childKey: nil)
            self.replaceUser(updateUser)
        }
        
        //Removed User
        firebaseApp.registerUserRemoveObserver { (dictionary, childKey) in
            let removedUser = Profile.loadStudentFromDictionary(dictionary, childKey: nil)
            self.removeUser(removedUser)
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
    
    func removeUser(_ removedUser: Profile) {
        for user in passportApp.users! {
            if user == removedUser {
                let index = passportApp.users?.index(of: user)
                self.passportApp.users?.remove(at: index!)
                DispatchQueue.main.async {
                    //Update Table in Main Queue, due to visible changes
                    self.usersTableView.reloadData()
                }
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
        //In case, we still sort by id Once user clear the search params
        self.passportApp.users = self.original?.sorted(by: { (a, b) -> Bool in
            a.id! < b.id!
        })
        self.usersTableView.reloadData()
        self.searchView.removeFromSuperview()
    }
    
    @IBAction func filterButton(_ sender: UIButton) {
        
        if !UserDefaults.standard.bool(forKey: kFirstSortNOTDone) {
            // Keep a original copy of DB, in case of sorting to restore as default
            self.original = self.passportApp.users
        } else {
            // Use original copy for the next filterings
            self.passportApp.users = self.original
        }
        
        // Sort base on params
        filterUsers()
        
        // Dismiss View
        self.searchView.removeFromSuperview()
    }
    
    @IBAction func closeFilterWindow(_ sender: UIButton) {
        self.searchView.removeFromSuperview()
    }
    
    
    func filterUsers() {
        /*
         0. A copy from original was ma in filterButton(_:)
         1. Assign the sorted or filtere to a temp var
         2. Remove items from singleton, not keeping the capacity
         3. Fill sIngletong with temp, if new filters
         */
        
        var test: Gender
        if self.genderSegementControll.selectedSegmentIndex == 0 {
            test = .Male
        } else {
            test = .Female
        }
        UserDefaults.standard.set(true, forKey: kFirstSortNOTDone)
        switch (self.nameAgeSegmentControl.selectedSegmentIndex, self.ascDescControl.selectedSegmentIndex, self.genderSegementControll.selectedSegmentIndex) {
        //FIXME: Use Enums
        case (0, 0, 0): // .Name by Ascending Order .Male
            let sortByName = self.passportApp.users?.sorted(by: { (a, b) -> Bool in
                a.name! < b.name!
            })
            
            let onlyMalesSortByName = sortByName?.filter({
                $0.sex == true
            })
            
            self.passportApp.users?.removeAll(keepingCapacity: false)
            self.passportApp.users = onlyMalesSortByName
            break
        case (0, 0, 0): // .Name by Descending Order .Male
            let sortByName = self.passportApp.users?.sorted(by: { (a, b) -> Bool in
                a.name! > b.name!
            })
            
            let onlyMalesSortByName = sortByName?.filter({
                $0.sex == true
            })
            
            self.passportApp.users?.removeAll(keepingCapacity: false)
            self.passportApp.users = onlyMalesSortByName
            break
        case (1, 0, 0): //  .Age by Ascending Order .Male
            let sortByAge = self.passportApp.users?.sorted(by: { (a, b) -> Bool in
                a.age! < b.age!
            })
            
            let onlyMalesSortByAge = sortByAge?.filter({
                $0.sex == true
            })
            
            self.passportApp.users?.removeAll(keepingCapacity: false)
            self.passportApp.users = onlyMalesSortByAge
            break
        case (1, 1, 0): // .Age by Descending Order .Male
            let sortByAge = self.passportApp.users?.sorted(by: { (a, b) -> Bool in
                a.age! < b.age!
            })
            
            let onlyMalesSortByAge = sortByAge?.filter({
                $0.sex == true
            })
            
            self.passportApp.users?.removeAll(keepingCapacity: false)
            self.passportApp.users = onlyMalesSortByAge
            break
        case (0, 1, 1): // .Names by Descending Order .Female
            let sortByName = self.passportApp.users?.sorted(by: { (a, b) -> Bool in
                a.name! > b.name!
            })
            
            let onlyFemalesSortByName = sortByName?.filter({
                $0.sex == false
            })
            
            self.passportApp.users?.removeAll(keepingCapacity: false)
            self.passportApp.users = onlyFemalesSortByName
            break
        case (0, 0, 1): // .Names by Ascending Order .Female
            let sortByName = self.passportApp.users?.sorted(by: { (a, b) -> Bool in
                a.name! > b.name!
            })
            
            let onlyFemalesSortByName = sortByName?.filter({
                $0.sex == false
            })
            
            self.passportApp.users?.removeAll(keepingCapacity: false)
            self.passportApp.users = onlyFemalesSortByName
            break
        case (1, 0, 1): // .Age by Ascending Order .Female
            let sortByAge = self.passportApp.users?.sorted(by: { (a, b) -> Bool in
                a.age! < b.age!
            })
            
            let onlyFemalesSortByAge = sortByAge?.filter({
                $0.sex == false
            })
            
            self.passportApp.users?.removeAll(keepingCapacity: false)
            self.passportApp.users = onlyFemalesSortByAge
            break
        case (1, 1, 1): // .Age by Descending Order .Female
            let sortByAge = self.passportApp.users?.sorted(by: { (a, b) -> Bool in
                a.age! > b.age!
            })
            
            let onlyFemalesSortByAge = sortByAge?.filter({
                $0.sex == false
            })
            
            self.passportApp.users?.removeAll(keepingCapacity: false)
            self.passportApp.users = onlyFemalesSortByAge
            break
        default:
            break
        }
        self.usersTableView.reloadData()
        UserDefaults.standard.set(true, forKey: kDataFiltered)
    }
    
    
    //MARK: - UITableViewDelegate DataSources
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.passportApp.users?.count {
            return count
        } else {
            // When no users had been saved
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        /*Delete Style*/
        if editingStyle == .delete {
            let deletedUser = passportApp.users?[indexPath.row]
            firebaseApp.removeProfileWith(deletedUser!, withCompletionHandler: { (success) in
                DispatchQueue.main.async {
                    if !success {
                        self.displayAlertWithError(message: "Error Deleting User")
                    } else {
                        for user in self.passportApp.users! {
                            if user == deletedUser {
                                let index = self.passportApp.users?.index(of: user)
                                self.passportApp.users?.remove(at: index!)
                            }
                        }
                    }
                }
            })
        }
    }
    
}

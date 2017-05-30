//
//  IntroViewController.swift
//  PassportApp
//
//  Created by Idelfonso Gutierrez Jr. on 5/29/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import UIKit
import Firebase

class IntroViewController: UIViewController {

    // MARK: Singleton
    var firebaseApp = FirebaseUserManager.sharedInstance
    var passportApp = PAData.sharedInstance

    // MARK: - App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseApp.configureDatabase()
        firebaseApp.configureStorage()
        //TODO: Init array of users, will this be reset everytime??
        self.passportApp.users = []
        loadFirebaseData()
    }
    
    deinit {
        firebaseApp.removeFirebaseObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let indicator = startActivityIndicatorAnimation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserListTableViewController") as! UserListTableViewController
            let navigationController = UINavigationController(rootViewController: controller)
            self.stopActivityIndicatorAnimation(indicator: indicator)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func loadFirebaseData() {
        firebaseApp.registerUserAddedObserver { (dictionary) in
            let user = Profile.loadStudentFromDictionary(dictionary)
            self.passportApp.users?.append(user)
            print(user.name)
        }
    }
}

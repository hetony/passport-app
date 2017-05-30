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
    var app = FirebaseUserManager.sharedInstance
    var data = PAData.shared()
    
    // Proeperties: Firebase
    var profilesSnapshortArray: [FIRDataSnapshot]! = []
    var storageRef: FIRStorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        app.configureDatabase()
        app.configureStorage()
        registerFirebaseObservers()
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

    func registerFirebaseObservers() {
        //New user added
        app.refHandle = app.ref.child(Path.Profiles).observe(.childAdded, with: { (snapshot) in
            print(snapshot.value as Any)
            self.profilesSnapshortArray.append(snapshot)
            let student = Profile.loadStudentFromDictionary(snapshot.value as! [String: Any])
            self.data.users?.append(student)
        })
        
        //User updated
        app.refHandle = app.ref.child(Path.Profiles).observe(.childChanged, with: { (updateSnapshot) in
            //TODO: look for key matching IDs
            let updatedUser = updateSnapshot.value as! [String: Any]
            print(updatedUser)
            //TODO: compare childs
            //TODO: Change values
        })
        
        //Init DB
        app.refHandle = app.ref.child(Path.Profiles).observe(.value, with: { (snapshot) in
            print(snapshot.value as Any)
            if !snapshot.exists() {
                self.data.users = []
//                let firstUser = Profile(id: 0, name: "test-user", age: 30, sex: "male", hobbies: ["hobby1", "hobby2"])
//                self.data.users?.append(firstUser)
            } else {
                self.profilesSnapshortArray.append(snapshot)
                let student = Profile.loadStudentFromDictionary(snapshot.value as! [String: Any])
                self.data.users?.append(student)
            }
        })
    }
}

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
    
    var profilesSnapshortArray: [FIRDataSnapshot]! = []
    var profileArray: [Profile]?
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
            self.stopActivityIndicatorAnimation(indicator: indicator)
            self.present(controller, animated: true, completion: nil)
        }
    }
    

    func registerFirebaseObservers() {
        app.refHandle = app.ref.child(Path.Profiles).observe(.childAdded, with: { (snapshot) in
            print(snapshot.value)
            self.profilesSnapshortArray.append(snapshot)
            let student = Profile.loadStudentFromDictionary(snapshot.value as! [String: Any])
            self.data.users = []
            self.data.users?.append(student)
        })
        
        app.refHandle = app.ref.child(Path.Profiles).observe(.childChanged, with: { (updateSnapshot) in
            //TODO: look for key matching IDs
            var updatedUser = updateSnapshot.value as! [String: Any]
            print(updatedUser)
            //TODO: compare childs
            //TODO: Change values
        })
    }
}

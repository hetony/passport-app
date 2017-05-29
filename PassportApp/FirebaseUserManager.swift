//
//  FirebaseUserManager.swift
//  PassportApp
//
//  Created by Idelfonso Gutierrez Jr. on 5/29/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import UIKit
import Firebase

class FirebaseUserManager: NSObject {

    static let sharedInstance = FirebaseUserManager()
    // MARK: - Properties
    var ref: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    var profilesSnapshortArray: [FIRDataSnapshot]! = []
    var profileArray: [Profile]?
    var storageRef: FIRStorageReference!

    // MARK: - Firebase
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
    }
    
    func configureStorage() {
        storageRef = FIRStorage.storage().reference()
    }
}

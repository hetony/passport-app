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
    fileprivate var _refHandle: FIRDatabaseHandle!             // Profiles path handle
    var profilesSnapshortArray: [FIRDataSnapshot]! = []
    var storageRef: FIRStorageReference!

    // MARK: - Firebase
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
    }
    
    func configureStorage() {
        storageRef = FIRStorage.storage().reference()
    }
    
    func sendProfile(data: [String: Any]) {
        ref.child(Path.Profiles).childByAutoId().setValue(data)
    }
    
    func registerUserAddedObserver(withCompletionHandler: @escaping(_ dictionary: [String: Any]) -> Void) {
        //New user added
        _refHandle = ref.child(Path.Profiles).observe(.childAdded, with: { (snapshot) in
            let addedUser = snapshot.value as! [String: Any]
            withCompletionHandler(addedUser)
        })
    }
    
    func registerUserUpdatedObserver(withCompletionHandler: @escaping(_ dictionary: [String: Any]) -> Void)  {
        //User updated
        _refHandle = ref.child(Path.Profiles).observe(.childChanged, with: { (updateSnapshot) in
            //TODO: look for key matching IDs
            let updatedUser = updateSnapshot.value as! [String: Any]
            withCompletionHandler(updatedUser)
        })
    }
    
    func registerUserRemoveObserver(withCompletionHandler: @escaping(_ dictionary: [String: Any]) -> Void){
        _refHandle = ref.child(Path.Profiles).observe(.childRemoved, with: { (snapshot) in
            let removedUser = snapshot.value as! [String: Any]
            withCompletionHandler(removedUser)
        })
    }
    
    func removeFirebaseObserver() {
        ref.removeObserver(withHandle: _refHandle)
    }
    
    func registerAnyChangeObserver() {
//        //Any data changes at a location or, recursively, at any child node.
//        if !(UserDefaults.standard.bool(forKey: kIsAppFirstLaunch)) {
//            _refHandle = ref.child(Path.Profiles).observe(.value, with: { (snapshot) in
//                print(snapshot.value as Any)
//                if !snapshot.exists() {
//                    //self.data.users = []
//                    UserDefaults.standard.set(true, forKey: kIsAppFirstLaunch)
//                } else {
//                    self.profilesSnapshortArray.removeAll()
//                    self.profilesSnapshortArray.append(snapshot)
//                    let count = snapshot.childrenCount
//                    var userSnpshot = self.profilesSnapshortArray[0]
//                    let user = userSnpshot.value as! [String: Any]
//                    let userName = user["name"] ?? "no-name"
//                    print(userName)
//                    for student in self.profilesSnapshortArray {
//                        let one = Profile.loadStudentFromDictionary(student.value as! [String: Any])
//                        print(one)
//                    }
//                }
//            })
//        } else {
//            print("App already launched")
//        }
    }
    
    func sendSampleImage(profileImage: UIImage?, userId: Int, completionHandler: @escaping (_ metadata: FIRStorageMetadata?, _ success: Bool) -> Void) {
        if let image = profileImage, let photoData = UIImageJPEGRepresentation(image, 0.8) {
            let imagePath = "profile_photos/\(userId)"
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storageRef.child(imagePath).put(photoData, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    completionHandler(nil, false)
                    return
                }
                
                guard let metadata = metadata else {
                    completionHandler(nil, false)
                    return
                }
                // use sendMessage to add imageURL to database
                //self.sendProfile(data: ["imageUrl": self.storageRef!.child((metadata?.path)!).description])
                completionHandler(metadata, true)
            }
        } else {
            completionHandler(nil, false)
        }
    }
}

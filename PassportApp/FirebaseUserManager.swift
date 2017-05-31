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

    // MARK: - Firebase Ref Config
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
    }
    
    func configureStorage() {
        storageRef = FIRStorage.storage().reference()
    }
    
    // MARK: - Send, Update, Remove Data
    func sendProfileWith(data: [String: Any]) {
        ref.child(Path.Profiles).childByAutoId().setValue(data)
    }
    
    func updateProfile(data: [String: Any], withAutoId pushId: String?) {
        ref.child(Path.Profiles).child(pushId!).updateChildValues(data) { (error, database) in
            guard error == nil else {
                print("There was an error updating the profile: \(error)")
                return
            }
        }
    }
    
    /* Dowloads the image from the reference path*/
    func setImageProfile(imageUrl: String, completionHandler: @escaping(_ imageData: AnyObject?) -> Void) {
        FIRStorage.storage().reference(forURL: imageUrl).data(withMaxSize: INT64_MAX){ (data, error) in
            
            let imageData = UIImage.init(data: data!, scale: 50)
            completionHandler(imageData)
        }
    }
    
    // MARK: - Observers
    
    /* NewUser observer */
    func registerUserAddedObserver(withCompletionHandler: @escaping(_ dictionary: [String: Any], _ withKey: String) -> Void) {
        _refHandle = ref.child(Path.Profiles).observe(.childAdded, with: { (snapshot) in
            let addedUser = snapshot.value as! [String: Any]
            withCompletionHandler(addedUser, snapshot.key)
        })
    }
    
    /* UpdateUser Observer */
    //FIXME: Missing implementation, not required.
    func registerUserUpdatedObserver(withCompletionHandler: @escaping(_ dictionary: [String: Any]) -> Void)  {
        _refHandle = ref.child(Path.Profiles).observe(.childChanged, with: { (updateSnapshot) in
            let updatedUser = updateSnapshot.value as! [String: Any]
            withCompletionHandler(updatedUser)
        })
    }
    
    /* RemoveUser Observer*/
    //FIXME: Missing implementation, not required.
    func registerUserRemoveObserver(withCompletionHandler: @escaping(_ dictionary: [String: Any]) -> Void){
        _refHandle = ref.child(Path.Profiles).observe(.childRemoved, with: { (snapshot) in
            let removedUser = snapshot.value as! [String: Any]
            withCompletionHandler(removedUser)
        })
    }
    
    /* Remove Firebase Observer with handle*/
    func removeFirebaseObserver() {
        ref.removeObserver(withHandle: _refHandle)
    }
    
    /* Send image with user ID base on Ints */
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

                completionHandler(metadata, true)
            }
        } else {
            completionHandler(nil, false)
        }
    }
}

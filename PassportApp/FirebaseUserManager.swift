//
//  FirebaseUserManager.swift
//  PassportApp
//
//  Created by Idelfonso Gutierrez Jr. on 5/29/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

//TODO: Use completion blocks for new, update, and remove childs to retrieve any errors and maybe let the user know bad connection

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
    /* Sends JSON data to 'profiles' node*/
    func sendProfileWith(data: [String: Any]) {
        ref.child(Path.Profiles).childByAutoId().setValue(data)
    }
    
    func removeProfileWith(_ pushId: String, withCompletionHandler: @escaping(_ success: Bool) -> Void) {
        ref.child(Path.Profiles).child(pushId).removeValue { (error, firebaseRed) in
            guard error == nil else {
                withCompletionHandler(false)
                return
            }
            withCompletionHandler(true)
        }
    }
    
    /* Updates the user porfile using the stored pushId from previous call*/
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
        /*
         Althought we are adding childs sequentially, one can sort the snapshot been retrieve by a specific key
         */
        _refHandle = ref.child(Path.Profiles).observe(.childAdded, with: { (snapshot) in
            let addedUser = snapshot.value as! [String: Any]
            let childKey = snapshot.key
            withCompletionHandler(addedUser, childKey)
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
    func registerUserRemoveObserver(withCompletionHandler: @escaping(_ dictionary: [String: Any], _ withKey: String) -> Void){
        _refHandle = ref.child(Path.Profiles).observe(.childRemoved, with: { (snapshot) in
            let removedUser = snapshot.value as! [String: Any]
            let childKey = snapshot.key
            withCompletionHandler(removedUser, childKey)
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

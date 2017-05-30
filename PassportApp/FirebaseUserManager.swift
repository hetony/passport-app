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
    var ref:                FIRDatabaseReference!
    var refHandle:          FIRDatabaseHandle!             // Profiles path handle
    var profilesSnapshortArray: [FIRDataSnapshot]! = []
    var storageRef:         FIRStorageReference!

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

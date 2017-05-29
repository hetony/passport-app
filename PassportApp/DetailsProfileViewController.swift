//
//  DetailsProfileViewController.swift
//  PassportApp
//
//  Created by Idelfonso Gutierrez Jr. on 5/27/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import UIKit

class DetailsProfileViewController: UIViewController {

    // MARK: - Singleton property
    var app = FirebaseUserManager.sharedInstance
    
    // MARK: - Properties
    var profile: Profile?
    var newUser: Bool?
    var arrayOfHobbies: [String]?
    
    // MARK: - IBOutlets
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var genderSwitch: UISwitch!
    @IBOutlet weak var genderLabel: UILabel!
    
    // MARK: - App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setImagePicker()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForNewProfile()
    }

    // MARK: - Setup UI
    func setupNavBar() {
        self.navigationController?.navigationBar.isTranslucent = false
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveProfileInfo))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    func setImagePicker() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pickAnImage))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Primary View Controller Functions
    func saveProfileInfo() {
        if validateFields() {
            let data: [String: Any] = [
                "id": "",   //TODO: get UUID
                "name": self.nameTextField.text,
                "age": self.ageTextField.text,
                "sex": "",
                "imageUrl": "g://asdsad"
            ]
            
            app.ref.child("profiles").childByAutoId().setValue(data)
        } else {
            displayAlertWithError(message: "Please fill up all the fields")
        }
        
    }
    
    func showUserProfile() {
        paintSexColor()
    }
    

    //MARK: - Secondary View Controller Functions
    func checkForNewProfile() {
        if let newUser = self.newUser, newUser == true {
            clearTextFields()
        } else {
            showUserProfile()
        }
    }
    
    func validateFields() -> Bool {
        if !(self.ageTextField.text?.isEmpty)!, !(self.nameTextField.text?.isEmpty)! {
            return true
        } else {
            return false
        }
    }
    
    func clearTextFields() {
        self.ageTextField.text = ""
        self.nameTextField.text = ""
        self.profileImageView.image = UIImage(named: "placeholder")
    }
    
    func paintSexColor() {
        profile?.sex = "male" 
        if profile?.sex == "male" {
            self.view.backgroundColor = UIColor.blue
        } else {
            self.view.backgroundColor = UIColor.green
        }
    }
    
//    func sendSampleImage() {
//        if let image = UIImage(named: "profilePhoto"), let photoData = UIImageJPEGRepresentation(image, 0.8) {
//            let imagePath = "profile_photos/\(firebase.pro)"
//            let metadata = FIRStorageMetadata()
//            metadata.contentType = "image/jpeg"
//            
//            storageRef.child(imagePath).put(photoData, metadata: metadata) { (metadata, error) in
//                if let error = error {
//                    print("Error uploading: \(error)")
//                    return
//                }
//                // use sendMessage to add imageURL to database
//                self.sendJSON(data: ["imageUrl": self.storageRef!.child((metadata?.path)!).description])
//            }
//        }
//    }
    
    // MARK: - IBActions
    @IBAction func switchPress(_ sender: UISwitch) {
        if genderSwitch.isOn {
            self.view.backgroundColor = UIColor.blue
            self.genderLabel.textColor = UIColor.white
            self.genderLabel.text = "MALE"
        } else {
            self.view.backgroundColor = UIColor.green
            self.genderLabel.textColor = UIColor.black
            self.genderLabel.text = "FEMALE"
        }
    }

}

extension DetailsProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pickAnImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
        } else {
            imagePickerController.sourceType = .photoLibrary
        }
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage, let photoData = UIImageJPEGRepresentation(photo, 0.8) {
            self.profileImageView.image = photo
//            app.sendPhoto(photoData: photoData)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

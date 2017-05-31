//
//  DetailsProfileViewController.swift
//  PassportApp
//
//  Created by Idelfonso Gutierrez Jr. on 5/27/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import UIKit

class DetailsProfileViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Singleton property
    var firebaseApp = FirebaseUserManager.sharedInstance
    var passportApp = PAData.sharedInstance
    
    // MARK: - Properties
    var profile: Profile?
    var arrayOfHobbies: [String]?
    
    // MARK: - IBOutlets
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var genderSwitch: UISwitch!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var hobbiesTextView: UITextView!
    
    // MARK: - App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setImagePicker()
        subscribeToKeyboardOffTap()

        self.hobbiesTextView.delegate = self
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
        if validateFields() {   // Check for all fields completed
            firebaseApp.sendSampleImage(profileImage: self.profileImageView.image, userId: (self.profile?.id)!, completionHandler: { (metadata, success) in
                if !success {   // Check for image place in Storage
                    print("Could not store image")
                } else {
                    let userData: [String: Any] = [
                        UserKeys.IDKey:       self.profile?.id!, //Doesnt belong to the child nodes
                        UserKeys.NameKey:     self.nameTextField.text!,
                        UserKeys.AgeKey:      Int(self.ageTextField.text!)!,
                        UserKeys.SexKey:      self.genderSwitch.isOn,
                        UserKeys.HobbiesKey:  self.hobbiesTextView.text!,
                        UserKeys.ImageURLKey: self.firebaseApp.storageRef!.child((metadata!.path)!).description,
                        UserKeys.NewUserKey:  false
                    ]
                    
                    if let newUser = self.profile?.newUser, newUser == true {
                        self.firebaseApp.sendProfileWith(data: userData)
                    } else {
                        self.firebaseApp.updateProfile(data: userData, withAutoId: self.profile?.pushId)
                    }
                    self.navigationController?.popViewController(animated: true)

                }
            })
        } else {
            displayAlertWithError(message: "Please fill up all the fields")
        }
        //TODO: send and array to play with it
    }
    
    func showUserProfile() {
        self.nameTextField.isEnabled = false
        self.ageTextField.isEnabled = false
        self.profileImageView.isUserInteractionEnabled = false
        
        if profile?.sex == true {
            self.view.backgroundColor = UIColor.blue
            self.genderLabel.text = "MALE"
            self.genderSwitch.isOn = true
        } else {
            self.view.backgroundColor = UIColor.green
            self.genderLabel.text = "FEMALE"
            self.genderSwitch.isOn = false
        }
        
        self.nameTextField.text = self.profile?.name
        self.ageTextField.text = "\(self.profile!.age!)"
        self.hobbiesTextView.text = self.profile?.hobbies
        
        let imageUrl = self.profile?.imageUrl
        firebaseApp.setImageProfile(imageUrl: imageUrl!) { (image) in
            DispatchQueue.main.async {
                if image != nil {
                    self.profileImageView.image = image as! UIImage
                } else  {
                   self.profileImageView.image = UIImage(named: "placeholder")
                }
            }
        }
    }

    //MARK: - Secondary View Controller Functions
    func checkForNewProfile() {
        if let newUser = self.profile?.newUser, newUser == true {
            clearTextFields()
        } else {
            showUserProfile()
        }
    }
    
    func validateFields() -> Bool {
        if !(self.ageTextField.text?.isEmpty)!, !(self.nameTextField.text?.isEmpty)!, !(self.genderLabel.text?.isEmpty)!, !(self.hobbiesTextView.text.isEmpty) {
            return true
        } else {
            return false
        }
    }
    
    func clearTextFields() {
        self.ageTextField.text = ""
        self.nameTextField.text = ""
        self.genderSwitch.isOn = true
        self.view.backgroundColor = UIColor.white
        self.genderLabel.text = "Gender Switcher"
    }
    
    
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

// MARK: -
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
            UserDefaults.standard.set(true, forKey: kSetProfilePicture)
            self.profileImageView.image = photo
        } else {
            print("something went wrong")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: -
extension DetailsProfileViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

// MARK: -
extension DetailsProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.hobbiesTextView.isFirstResponder {
            self.view.frame.origin.y = 190 * -1
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.frame.origin.y = 65
    }
}

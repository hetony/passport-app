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
    @IBOutlet weak var sexSwitch: UISegmentedControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var hobbiesTableView: UITableView!
    
    // MARK: - App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setupNavBar()
        setImagePicker()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForNewProfile()
    }

    // MARK: - Setup UI
    func setupNavBar() {
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveProfileInfo))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    func setImagePicker() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pickAnImage))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
    }

    //MARK: - View Controller
    func checkForNewProfile() {
        if let newUser = newUser {
            if newUser {
                clearTextFields()
            } else {
                showUserProfile()
            }
        }
    }
    
    func saveProfileInfo() {
        let data: [String: Any] = [
            "name": "Idelfonso",
            "age": 22,
            "sex": "M",
            "imageUrl": "g://asdsad"
        ]
        
        app.ref.child("profiles").childByAutoId().setValue(data)
    }
    
    func showUserProfile() {
        paintSexColor()
        
    }
    
    func clearTextFields() {
        
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
    
    
    @IBAction func sexSwitchChanged(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
    }

}

extension DetailsProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setTableView() {
        self.hobbiesTableView.delegate = self
        self.hobbiesTableView.dataSource = self
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: show
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
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage, let photoData = UIImageJPEGRepresentation(photo, 0.8) {
//            sendPhoto(photoData: photoData)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

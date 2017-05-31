//
//  Profile.swift
//  PassportApp
//
//  Created by Idelfonso Gutierrez Jr. on 5/27/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import Foundation

struct Profile {
    
    // MARK: - Properties
    var id: Int?
    var name: String?
    var age: Int?
    var sex: Bool?
    var hobbies: String?
    var newUser: Bool?
    var imageUrl: String?
    
    
    // MARK: - Functions
    static func loadStudentFromDictionary(_ dictionary: [String: Any]) -> Profile {
        return self.init(id: dictionary["id"] as! Int,
                         name: dictionary["name"] as! String,
                         age: dictionary["age"] as! Int,
                         sex: dictionary["sex"] as! Bool,
                         hobbies: dictionary["hobbies"] as! String,
                         newUser: dictionary["newUser"] as! Bool,
                         imageUrl: dictionary["imageUrl"] as! String)
    }
}

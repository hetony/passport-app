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
    var id: String?
    var name: String?
    var age: Int?
    var sex: String?
    var hobbies: [String]?
    
    // MARK: - Functions
    static func loadStudentFromDictionary(_ dictionary: [String: Any]) -> Profile {
        return self.init(id: dictionary["id"] as? String,
                         name: dictionary["name"] as? String,
                         age: dictionary["age"] as? Int,
                         sex: dictionary["sex"] as? String,
                         hobbies: dictionary["hobbies"] as? [String])
    }
}

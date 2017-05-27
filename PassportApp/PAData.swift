//
//  PAData.swift
//  PassportApp
//
//  Created by Idelfonso Gutierrez Jr. on 5/27/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import UIKit

class PAData: NSObject {
    var users: [Profile]?
    var myProfile: Profile?
    
    static func shared() -> PAData {
        struct Singleton {
            static var sharedInstance = PAData()
        }
        return Singleton.sharedInstance
    }
}

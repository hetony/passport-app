//
//  IntroViewController.swift
//  PassportApp
//
//  Created by Idelfonso Gutierrez Jr. on 5/29/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let indicator = startActivityIndicatorAnimation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserListTableViewController") as! UserListTableViewController
            self.stopActivityIndicatorAnimation(indicator: indicator)
            self.present(controller, animated: true, completion: nil)
        }
    }
    

}

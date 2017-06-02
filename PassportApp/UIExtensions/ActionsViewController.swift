//
//  ActionsViewController.swift
//  udacity-on-the-map
//
//  Created by Idelfonso Gutierrez Jr. on 5/25/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    //MARK: Activity Indicator
    func startActivityIndicatorAnimation() -> UIActivityIndicatorView {
    
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.center = self.view.center
        activityIndicator.frame = self.view.frame
        activityIndicator.color = UIColor.darkGray
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        return activityIndicator
    }
    
    func stopActivityIndicatorAnimation(indicator: UIActivityIndicatorView) {
        indicator.stopAnimating()
    }


    //MARK: Alerts
    
    //Execute it in the main queue
    func displayAlertWithError(message: String) {
        let controller = UIAlertController(title: "Error",
                                           message: message,
                                           preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: nil)
        
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    

    func overwriteLocationWith(_ completeAction: @escaping () -> Void, message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .destructive, handler: nil)
        let okAction = UIAlertAction(title: "ok", style: .default) { (action) in
            DispatchQueue.main.async {
                completeAction()
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    //Random
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func subscribeToKeyboardOffTap()  {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: self)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: self)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        self.view.frame.origin.y = getKeyboardHeight(notification) * -1
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardFrame.cgRectValue.height
    }
}

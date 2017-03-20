//
//  StartupViewController.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 3/18/17.
//  Copyright © 2017 Nicole Marvin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBAction func toWorkoutScreen(_ sender: Any) {
        userName = userTextField.text!
        self.dismiss(animated: false, completion: nil)
    }
    @IBOutlet weak var userTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Keyboard dismissal (next three lines of code) modified from Esquarrouth on StackOverflow
        // http://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift/35560948
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SetWorkoutViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

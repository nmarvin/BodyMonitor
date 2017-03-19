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
        self.dismiss(animated: false, completion: nil)
    }
    @IBOutlet weak var userTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

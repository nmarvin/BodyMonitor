//
//  RpeViewController.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 2/24/17.
//  Copyright © 2017 Nicole Marvin. All rights reserved.
//

import UIKit

class RpeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var rpePickerView: UIPickerView!
    let rpeOptions = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var currentRow = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        rpePickerView.delegate = self
        rpePickerView.dataSource = self
    }

    @IBAction func close() {
        if(currentRow >= 0) {
            dismiss(animated: true, completion: nil)
            // send rpe: currentRow + 1
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: rpeNotification), object: nil)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rpeOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentRow = row
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    } 
}

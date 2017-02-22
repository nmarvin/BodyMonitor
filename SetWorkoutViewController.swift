//
//  SetWorkoutViewController.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 2/15/17.
//  Copyright © 2017 Nicole Marvin. All rights reserved.
//

import UIKit

class SetWorkoutViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var rpeQueryType: UILabel!
    @IBOutlet weak var rpeQueryPickerView: UIPickerView!
    @IBOutlet weak var askMeLabel: UILabel!
    
    let rpeQueryOptions = ["By Time Interval", "By Heart Rate", "By Speed", "At Workout Conclusion"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rpeQueryPickerView.delegate = self
        rpeQueryPickerView.dataSource = self
    }
    
    // when the user presses "Go!", return to the main screen
    @IBAction func close(_ sender: Any) {
        //TODO: store the preferred RPE query method; set a notification thingy for querying and recording
        dismiss(animated: true, completion: nil)
    }
    
    // when the user wants to change the rpe query method, show the picker
    @IBAction func handleTapWithRecognizer(_ sender: Any) {
        rpeQueryPickerView.isHidden = !rpeQueryPickerView.isHidden
    }
    
    // when an rpe method is selected, hide the picker
    @IBAction func handleTapSelectQuery(_ sender: Any) {
        rpeQueryPickerView.isHidden = true
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rpeQueryOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rpeQueryOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        rpeQueryType.text = rpeQueryOptions[row]
        pickerView.isHidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

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
    @IBOutlet weak var targetHeartRateText: UITextField!
    @IBOutlet weak var intervalPicker: UIDatePicker!
    @IBOutlet weak var addIntervalButton: UIButton!
    @IBOutlet weak var deleteIntervalButton: UIButton!
    @IBOutlet weak var intervalText: UITextView!
    
    let BY_TIME = "By Time Interval"
    let BY_HR = "By Heart Rate"
    let BY_END = "At Workout Conclusion"
    
    var rpeQueryOptions: [String] = []
    var queryType = "At Workout Conclusion"
    var currentInterval: TimeInterval = 0.0
    var cumulativeTime: TimeInterval = 0.0
    var rpeIntervals: [TimeInterval] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        intervalPicker.countDownDuration = 60
        rpeQueryOptions = [BY_TIME, BY_HR, BY_END]
        rpeQueryPickerView.delegate = self
        rpeQueryPickerView.dataSource = self
        targetHeartRateText.isHidden = true
        intervalPicker.isHidden = true
        addIntervalButton.isHidden = true
        deleteIntervalButton.isHidden = true
        //Keyboard dismissal (next three lines of code) modified from Esquarrouth on StackOverflow
        // http://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift/35560948
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // keyboard scrolling modified from Boris on StackOverflow
        // http://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    @IBAction func intervalUpdated(_ sender: Any) {
        currentInterval = intervalPicker.countDownDuration
    }
    
    @IBAction func intervalAdded(_ sender: Any) {
        print(String(currentInterval))
        cumulativeTime += currentInterval
        rpeIntervals.append(cumulativeTime)
        var minutes = Int(currentInterval)
        minutes = minutes/60
        let secondsTime = currentInterval - 60.0 * Double(minutes)
        let seconds = Int(secondsTime) / 1
        if let oldText = intervalText.text {
            intervalText.text = "\(oldText) \n\(String(minutes)):\(String(format:"%02d",seconds))"
        }
        else {
            intervalText.text = "\(String(minutes)):\(String(format:"%02d",seconds))"
        }
    }
    
    @IBAction func intervalDeleted(_ sender: Any) {
        if rpeIntervals.count > 0 {
            let oldInterval = rpeIntervals.remove(at: rpeIntervals.count - 1)
            if rpeIntervals.count > 0 {
                cumulativeTime = rpeIntervals[rpeIntervals.count - 1]
            }
            else {
                cumulativeTime = 0.0
            }
            // update text view
            if let theText = intervalText.text {
                var newText = theText
                print(newText)
                while(newText.characters.last != "\n") {
                    newText.remove(at: newText.index(before: newText.endIndex))
                }
                // remove the last newline
                newText.remove(at: newText.index(before: newText.endIndex))
                intervalText.text = newText
            }
        }
    }
    
    // when the user presses "Go!", save RPE query method and return to the main screen
    @IBAction func close(_ sender: Any) {
        //TODO: store the preferred RPE query method; set a notification thingy for querying and recording
        if queryType == BY_TIME {
            targetIntervals = rpeIntervals
        }
        else if queryType == BY_HR {
            if let newTargetHeartRate = targetHeartRateText.text {
                let trimmedTarget = newTargetHeartRate.trimmingCharacters(in: .whitespaces)
                if let theTarget = UInt8(trimmedTarget) {
                    targetHeartRate = theTarget
                }
            }
        }
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
        queryType = rpeQueryOptions[row]
        rpeQueryType.text = queryType
        if(queryType == BY_HR) {
            targetHeartRateText.isHidden = false
        }
        else {
            targetHeartRateText.isHidden = true
        }
        
        if(queryType == BY_TIME) {
            intervalPicker.isHidden = false
            addIntervalButton.isHidden = false
            deleteIntervalButton.isHidden = false
        }
        else {
            intervalPicker.isHidden = true
            addIntervalButton.isHidden = true
            deleteIntervalButton.isHidden = true
        }
        
        pickerView.isHidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // keyboardWillShow modified from Boris on StackOverflow
    // http://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    // keyboardWillHide modified from Boris on StackOverflow
    // http://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}

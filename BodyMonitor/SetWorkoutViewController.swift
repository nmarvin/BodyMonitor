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
    @IBOutlet weak var targetHeartRateText: AllowedCharsTextField!
    @IBOutlet var setTargetHeartRateView: UIView!
    @IBOutlet weak var hrChildContainer: UIView!
    @IBOutlet weak var intervalChildContainer: UIView!
    
    let BY_TIME = "By Time Interval"
    let BY_HR = "By Heart Rate"
    let BY_SPEED = "By Speed"
    let BY_END = "At Workout Conclusion"
    
    var rpeQueryOptions: [String] = []
    var queryType = "At Workout Conclusion"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rpeQueryOptions = [BY_TIME, BY_HR, BY_SPEED, BY_END]
        rpeQueryPickerView.delegate = self
        rpeQueryPickerView.dataSource = self
        hrChildContainer.isHidden = true
        intervalChildContainer.isHidden = true
        //Keyboard dismissal (next three lines of code) modified from Esquarrouth on StackOverflow
        // http://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift/35560948
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SetWorkoutViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // keyboard scrolling modified from Boris on StackOverflow
        // http://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    // when the user presses "Go!", save RPE query method and return to the main screen
    @IBAction func close(_ sender: Any) {
        //TODO: store the preferred RPE query method; set a notification thingy for querying and recording
        if queryType == BY_TIME {
            
        }
        else if queryType == BY_HR {
            
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
            hrChildContainer.isHidden = false
        }
        else {
            hrChildContainer.isHidden = true
        }
        
        if(queryType == BY_TIME) {
            intervalChildContainer.isHidden = false
        }
        else {
            intervalChildContainer.isHidden = true
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

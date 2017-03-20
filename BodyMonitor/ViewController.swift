//
//  ViewController.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 12/17/16.
//  Copyright © 2016 Nicole Marvin. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation
import MessageUI

// global variables based off BLE specifications
// service UUIDS
let POLARH7_HRM_DEVICE_INFO_SERVICE_UUID = CBUUID(string: "180A")
let POLARH7_HRM_HEART_RATE_SERVICE_UUID = CBUUID(string: "180D")
let POLAR_STRIDE_RSC_SERVICE_UUID = CBUUID(string: "1814")
let serviceUUIDS = [POLARH7_HRM_HEART_RATE_SERVICE_UUID, POLARH7_HRM_DEVICE_INFO_SERVICE_UUID, POLAR_STRIDE_RSC_SERVICE_UUID]

// characteristic UUIDs
let POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID = CBUUID(string: "2A37")
let POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID = CBUUID(string: "2A29")
let POLAR_STRIDE_RSC_MEASUREMENT_CHARACTERISTIC_UUID = CBUUID(string: "2A53")
let POLAR_STRIDE_RSC_FEATURE_CHARACTERISTIC_UUID = CBUUID(string: "2A54")
let characteristicUUIDS = [POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID, POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID, POLAR_STRIDE_RSC_MEASUREMENT_CHARACTERISTIC_UUID, POLAR_STRIDE_RSC_FEATURE_CHARACTERISTIC_UUID]

// get Bluetooth fired up
let myManagerDelegate = MyCentralManagerDelegate()
let myManager = CBCentralManager(delegate: myManagerDelegate, queue: nil)

// notification messages
let hrmNotification = "Heart Rate Updated"
let rscNotification = "RSC Updated"
let rpeNotification = "RPE Updated"

// display variables for sensor data
// cadence: unsigned byte (max 254); heart rate: positive byte; speed: double; distance: double
var hrm: UInt8? = nil
var currentSpeed: Double? = nil
var currentCadence: UInt8? = nil
var currentStrideLength: Double? = nil
var currentTotalDistance: Double? = nil
var currentRpe: Int? = nil
var endWorkout: Bool = false
var userName: String = "user"

class ViewController: UIViewController {
    // instantiate timers
    var durationTimer = Timer()
    var recordingTimer = Timer()
    var startTime = TimeInterval()
    var pauseTime = TimeInterval()
    var totalPausedTime = TimeInterval()
    // variables for keeping time
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    var milliseconds: Int = 0
    var timeIsRunning: Bool = false
    var timeIsPaused: Bool = false
    var dateTime: [TimeInterval] = []
    var heartRate: [UInt8?] = []
    var speed: [Double?] = []
    var cadence: [UInt8?] = []
    var indices: [Int] = []
    var rpe: [(TimeInterval,Int)] = []
    
    // should the view present the login screen?
    var showLogin: Bool = true
    
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var cadenceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mostSignificantTimeDigit: UILabel!
    @IBOutlet weak var middleSignificantTimeDigit: UILabel!
    @IBOutlet weak var timePunctuation: UILabel!
    @IBOutlet weak var leastSignificantTimeDigit: UILabel!
    @IBOutlet weak var stopButtonLabel: UIButton!
    @IBOutlet weak var customizeWorkoutButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    
    @IBAction func startTime(_ sender: Any) {
        print("user is: " + userName)
        if !self.timeIsRunning {
            if !self.timeIsPaused {
                stopButton.isEnabled = true
                customizeWorkoutButton.isEnabled = false
                
                startTime = Date.timeIntervalSinceReferenceDate
                // start with no paused time
                totalPausedTime = startTime - startTime
                
            }
            else {
                stopButton.isEnabled = true
                stopButtonLabel.setTitle("Stop", for: .normal)
                totalPausedTime += (Date.timeIntervalSinceReferenceDate - pauseTime)
                self.timeIsPaused = false
            }
            durationTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.updateTime), userInfo: nil, repeats: true)
            recordingTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.recordData), userInfo: nil, repeats: true)
            self.timeIsRunning = true
        }
    }
    
    @IBAction func stopTime(_ sender: Any) {
        if self.timeIsRunning {
            durationTimer.invalidate()
            recordingTimer.invalidate()
            pauseTime = Date.timeIntervalSinceReferenceDate
            timeIsRunning = false
            timeIsPaused = true
            stopButton.isHidden = true
            stopButton.isEnabled = false
            endButton.isHidden = false
            endButton.isEnabled = true
            //stopButtonLabel.setTitle("End", for: .normal)
            //print("Length of date array: \(dateTime.count)")
            //print("Length of hrm array: \(heartRate.count)")
            //print("Length of cadence array: \(cadence.count)")
            //print("Length of speed array: \(speed.count)")
        }
        else {
            // query for RPE
            getRpe()
            customizeWorkoutButton.isEnabled = true
        }
    }
    
    @IBAction func endTime(_ sender: Any) {
        endButton.isEnabled = false
        endButton.isHidden = true
        stopButton.isHidden = false
        getRpe()
        customizeWorkoutButton.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.isEnabled = false
        endButton.isEnabled = false
        endButton.isHidden = true
        
        // listen for notifications from sensors and other views
        NotificationCenter.default.addObserver(self, selector: #selector(displayHeartRate), name: NSNotification.Name(rawValue: hrmNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayRSC), name: NSNotification.Name(rawValue: rscNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recordRpe), name: NSNotification.Name(rawValue: rpeNotification), object: nil)
        
        // begin scanning for the necessary devices
        if myManager.state == .poweredOn {
            myManager.scanForPeripherals(withServices: serviceUUIDS, options: nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(showLogin) {
            //immediately show the login screen
            self.performSegue(withIdentifier: "loginSegue", sender: self)
            showLogin = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // prepare for a new workout
    func reset() {
        stopButton.isEnabled = false
        endButton.isEnabled = false
        endButton.isHidden = true
        endWorkout = false
    }
    
    // display a new heart rate
    func displayHeartRate() {
        if let heartRate = hrm {
            heartRateLabel.text = String(heartRate)
        }
    }
    
    // display data from the foot pod
    func displayRSC() {
        if let theCurrentSpeed = currentSpeed {
            speedLabel.text = String(theCurrentSpeed)
        }
        if let theCurrentCadence = currentCadence {
            cadenceLabel.text = String(theCurrentCadence)
        }
        if let theCurrentTotalDistance = currentTotalDistance {
            distanceLabel.text = String(theCurrentTotalDistance)
        }
    }
    
    // calculate the elapsed time
    func updateTime() {
        let currentTime = Date.timeIntervalSinceReferenceDate
        var elapsedTime: TimeInterval = (currentTime - startTime) - totalPausedTime
        
        self.hours = Int(elapsedTime / (60 * 60)) // hours conversion = seconds * (1 minute / 60 seconds) * (1 hour / 60 minutes)
        elapsedTime -= TimeInterval(hours) * 60 * 60
        
        self.minutes = Int(elapsedTime / 60)
        elapsedTime -= TimeInterval(minutes) * 60
        
        self.seconds = Int(elapsedTime / 1)
        elapsedTime -= TimeInterval(seconds)
        
        // get fractional seconds to two decimal places
        self.milliseconds = Int(elapsedTime * 100)
        displayTime();
    }

    // display time on the view
    func displayTime() {
        var millisecondsString: String
        var secondsString: String
        var minutesString: String
        
        if self.milliseconds < 10 {
            millisecondsString = "0" + String(self.milliseconds)
        }
        else {
            millisecondsString = String(self.milliseconds)
        }
        
        if self.seconds < 10 {
            secondsString = "0" + String(self.seconds)
        }
        else {
            secondsString = String(self.seconds)
        }
        
        if self.minutes < 10 {
            minutesString = "0" + String(self.minutes)
        }
        else {
            minutesString = String(self.minutes)
        }
        
        if self.hours < 1 {
            mostSignificantTimeDigit.text = minutesString
            middleSignificantTimeDigit.text = secondsString
            timePunctuation.text = "."
            leastSignificantTimeDigit.text = millisecondsString
        }
        else {
            mostSignificantTimeDigit.text = String(self.hours)
            middleSignificantTimeDigit.text = minutesString
            timePunctuation.text = ":"
            leastSignificantTimeDigit.text = secondsString
        }
    }
    
    // store data for writing to file
    func recordData() {
        dateTime.append(Date.timeIntervalSinceReferenceDate)
        heartRate.append(hrm)
        speed.append(currentSpeed)
        cadence.append(currentCadence)
    }
    
    // store RPE data for writing to file (currentTime defaults to now if it is unspecified)
    func recordRpe(_ currentTime: TimeInterval = Date.timeIntervalSinceReferenceDate) {
        if let unwrappedRpe = currentRpe {
        dateTime.append(currentTime)
        rpe.append(currentTime, unwrappedRpe)
        indices.append(dateTime.count)
        heartRate.append(hrm)
        speed.append(currentSpeed)
        cadence.append(currentCadence)
        }
        if endWorkout {
            print("exporting")
            exportData()
        }
    }

    // write data to a file
    func exportData() {
        // since we want the user to access her/his file, store in Documents/
        print("Data export")
        
        // build a long, long string
        let myFileContents = "test file"
        
        // code for directory creation modivied from http://stackoverflow.com/questions/1762836/create-a-folder-inside-documents-folder-in-ios-apps
        // get the path to "Documents", where user data should be stored
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        // create the custom folder path
        if let userDirectoryPath = documentDirectoryPath?.appending("/" + userName) {
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: userDirectoryPath) {
                do {
                    try fileManager.createDirectory(atPath: userDirectoryPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                    print("user directory created")
                } catch {
                    print("Error creating user folder in documents dir: \(error)")
                }
            }
            
            // give the current file a timestamp
            let file = CACurrentMediaTime()
            // name the file with its extension
            let fileName = String(file) + ".tcx"
            
            //write the file
            do{
                print("trying to save")
                try myFileContents.write(toFile: userDirectoryPath.appending(fileName),atomically: true, encoding: String.Encoding.utf8 )
                //print("workout saved")
                // alert code in try and catch statements modified from Brian Moakley's Beginning iOS 10 Part 1 Getting Started: Alerting the user https://videos.raywenderlich.com/courses/beginning-ios-10-part-1-getting-started/lessons/6
                let alertController = UIAlertController(title: "BodyMonitor", message: "Workout Saved!", preferredStyle: .alert)
                let actionItem = UIAlertAction(title: "Ok", style: .default)
                 alertController.addAction(actionItem)
                present(alertController, animated: true, completion: nil)
                } catch{
                //print("save failed")
                let alertController = UIAlertController(title: "BodyMonitor", message: "Save Failed", preferredStyle: .alert)
                let actionItem = UIAlertAction(title: "Ok", style: .default)
                 alertController.addAction(actionItem)
                present(alertController, animated: true, completion: nil)
                }
            }
        print("resetting")
        reset()
    }
    
    // query for RPE
    func getRpe() {
        endWorkout = true
        // show the new screen over the current one; time will keep running, etc.
        self.performSegue(withIdentifier: "rpeSegue", sender: self)
        // wait for child view to disappear, then export data
        /*while (currentRpe == nil) {
            continue
        }*/
    }
}

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

// global variables based off BLE specifications
// first: service UUIDS
let POLARH7_HRM_DEVICE_INFO_SERVICE_UUID = CBUUID(string: "180A")
let POLARH7_HRM_HEART_RATE_SERVICE_UUID = CBUUID(string: "180D")
let POLAR_STRIDE_RSC_SERVICE_UUID = CBUUID(string: "1814")
let serviceUUIDS = [POLARH7_HRM_HEART_RATE_SERVICE_UUID, POLARH7_HRM_DEVICE_INFO_SERVICE_UUID, POLAR_STRIDE_RSC_SERVICE_UUID]

// second: characteristic UUIDs
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
let rsc1Notification = "RSC Updated, Pod 1"
let rsc2Notification = "RSC Updated, Pod 2"

// variables for RPE querying

// display variables for sensor data
// cadence: unsigned byte (max 254); heart rate: positive byte; speed: double; distance: double
var hrm: UInt8? = nil
var speed1: Double? = nil
var cadence1: UInt8? = nil
var strideLength1: Double? = nil
var totalDistance1: Double? = nil
var speed2: Double? = nil
var cadence2: UInt8? = nil
var strideLength2: Double? = nil
var totalDistance2: Double? = nil

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
    
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var speed1Label: UILabel!
    @IBOutlet weak var cadence1Label: UILabel!
    @IBOutlet weak var distance1Label: UILabel!
    @IBOutlet weak var speed2Label: UILabel!
    @IBOutlet weak var cadence2Label: UILabel!
    @IBOutlet weak var distance2Label: UILabel!
    @IBOutlet weak var mostSignificantTimeDigit: UILabel!
    @IBOutlet weak var middleSignificantTimeDigit: UILabel!
    @IBOutlet weak var timePunctuation: UILabel!
    @IBOutlet weak var leastSignificantTimeDigit: UILabel!
   
    @IBAction func startTime(_ sender: Any) {
        if !self.timeIsRunning {
            if !self.timeIsPaused {
                
                startTime = Date.timeIntervalSinceReferenceDate
                // start with no paused time
                totalPausedTime = startTime - startTime
                
            }
            else {
                totalPausedTime += (Date.timeIntervalSinceReferenceDate - pauseTime)
                self.timeIsPaused = false
            }
            durationTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.updateTime), userInfo: nil, repeats: true)
            recordingTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.recordData), userInfo: nil, repeats: true)
            self.timeIsRunning = true
            recordData()
        }
    }
    
    @IBAction func stopTime(_ sender: Any) {
        if self.timeIsRunning {
            durationTimer.invalidate()
            recordingTimer.invalidate()
            pauseTime = Date.timeIntervalSinceReferenceDate
            timeIsRunning = false
            timeIsPaused = true
            print("Length of date array: \(dateTime.count)")
            print("Length of hrm array: \(heartRate.count)")
            print("Length of cadence array: \(cadence.count)")
            print("Length of speed array: \(speed.count)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // listen for notifications from three sensors
        NotificationCenter.default.addObserver(self, selector: #selector(displayHeartRate), name: NSNotification.Name(rawValue: hrmNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayRSC1), name: NSNotification.Name(rawValue: rsc1Notification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayRSC2), name: NSNotification.Name(rawValue: rsc2Notification), object: nil)
        
        // begin scanning for the necessary devices
        if myManager.state == .poweredOn {
            myManager.scanForPeripherals(withServices: serviceUUIDS, options: nil)
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // display a new heart rate
    func displayHeartRate() {
        if let heartRate = hrm {
            heartRateLabel.text = String(heartRate)
        }
    }
    
    // display data from the first foot pod
    func displayRSC1() {
        if let currentSpeed1 = speed1 {
            speed1Label.text = String(currentSpeed1)
        }
        if let currentCadence1 = cadence1 {
            cadence1Label.text = String(currentCadence1)
        }
        if let currentDistance1 = totalDistance1 {
            distance1Label.text = String(currentDistance1)
        }
    }
    
    // display data from the second foot pod
    func displayRSC2() {
        if let currentSpeed2 = speed2 {
            speed2Label.text = String(currentSpeed2)
        }
        if let currentCadence2 = cadence2 {
            cadence2Label.text = String(currentCadence2)
        }
        if let currentDistance2 = totalDistance2 {
            distance2Label.text = String(currentDistance2)
        }
    }
    
    // calculate the elapsed time
    func updateTime() {
        var currentTime = Date.timeIntervalSinceReferenceDate
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
        speed.append(speed1)
        cadence.append(cadence1)
        
    }
    
    // write data to a file
    func exportData() {
        // consider storing in Library/Application support/ (...or maybe consider it user data and store in Documents/ ?)
        
    }
}

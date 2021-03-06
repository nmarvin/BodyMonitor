//
//  ViewController.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 12/17/16.
//  Copyright © 2016 Nicole Marvin. All rights reserved.
//

import UIKit
import UserNotifications
import CoreBluetooth
import CoreLocation
import AudioToolbox

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

// set up location services
let myLocationDelegate = MyCoreLocationManagerDelegate()
let myLocationManager = CLLocationManager()


// notification messages
let workoutNotification = "Workout created"
let hrmNotification = "Heart Rate Updated"
let hrmTargetNotification = "Target Heart Rate Reached"
let rscNotification = "RSC Updated"
let rpeNotification = "RPE Updated"

// workout customizability
var targetHeartRate: UInt8? = nil
var targetHrHit: Bool = false
var targetIntervals: [Double] = []
var targetTimers: [Timer] = []


// display variables for sensor data
// cadence: unsigned byte (max 254); heart rate: positive byte; speed: double; distance: double
var hrm: UInt8? = nil
var currentSpeed: Double? = nil
var currentCadence: UInt8? = nil
var currentStrideLength: Double? = nil
var currentTotalDistance: Double? = nil
var currentRpe: Int? = nil
var currentLatitude: Double? = nil
var currentLongitude: Double? = nil
var currentAltitude: Double? = nil
var endWorkout: Bool = false
var gettingRpe: Bool = false
var userName: String = ""
var timeIsRunning: Bool = false
var timeIsPaused: Bool = false

class ViewController: UIViewController {
    // instantiate timers
    var durationTimer = Timer()
    var recordingTimer = Timer()
    var startTime = TimeInterval()
    var pauseTime = TimeInterval()
    var totalPausedTime = TimeInterval()
    var totalElapsedTime = TimeInterval()
    var rpeTime = TimeInterval()
    // variables for keeping time
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    var milliseconds: Int = 0
    var dateTime: [TimeInterval] = []
    var heartRate: [UInt8?] = []
    var speed: [Double?] = []
    var distance: [Double?] = []
    var cadence: [UInt8?] = []
    var latitudes: [Double?] = []
    var longitudes: [Double?] = []
    var altitudes: [Double?] = []
    var rpe: [(TimeInterval,Int)] = []
    
    // should the view present the login screen?
    var showLogin: Bool = true
    
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var cadenceLabel: UILabel!
    @IBOutlet weak var mostSignificantTimeDigit: UILabel!
    @IBOutlet weak var middleSignificantTimeDigit: UILabel!
    @IBOutlet weak var timePunctuation: UILabel!
    @IBOutlet weak var leastSignificantTimeDigit: UILabel!
    @IBOutlet weak var customizeWorkoutButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var inputRpeButton: UIButton!
    
    @IBAction func createWorkout(_ sender: Any) {
        startButton.isEnabled = true
    }
    @IBAction func startTime(_ sender: Any) {
        if !timeIsRunning {
            // do all the startup stuff
            if !timeIsPaused {
                startButton.isEnabled = false
                stopButton.isEnabled = true
                customizeWorkoutButton.isHidden = true
                customizeWorkoutButton.isEnabled = false
                inputRpeButton.isHidden = false
                inputRpeButton.isEnabled = true
                
                startTime = Date.timeIntervalSinceReferenceDate
                // start with no paused time and no elapsed time
                totalPausedTime = startTime - startTime
                totalElapsedTime = startTime - startTime
                
                // set timers for target intervals
                if targetIntervals.count > 0 {
                    for i in 0...targetIntervals.count-1 {
                        targetTimers.append(Timer.scheduledTimer(timeInterval: targetIntervals[i], target: self, selector: #selector(ViewController.getRpe), userInfo: nil, repeats: false))
                    }
                }
                // start listening for target heart rate
                if let theTarget = targetHeartRate {
                    NotificationCenter.default.addObserver(self, selector: #selector(getRpe), name: NSNotification.Name(rawValue: hrmTargetNotification), object: nil)
                }
                
            }
            else {
                startButton.isEnabled = false
                endButton.isEnabled = false
                endButton.isHidden = true
                stopButton.isEnabled = true
                stopButton.isHidden = false
                totalPausedTime += (Date.timeIntervalSinceReferenceDate - pauseTime)
                timeIsPaused = false
                
                let currentTime = Date.timeIntervalSinceReferenceDate
                let elapsedTime: TimeInterval = (currentTime - startTime) - totalPausedTime
                if targetIntervals.count > 0 {
                    for i in 0...targetIntervals.count-1 {
                        if(targetIntervals[i] - elapsedTime > 0) {
                            targetTimers.append(Timer.scheduledTimer(timeInterval: targetIntervals[i] - elapsedTime, target: self, selector: #selector(ViewController.getRpe), userInfo: nil, repeats: false))
                        }
                    }
                }
                
            }
            durationTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.updateTime), userInfo: nil, repeats: true)
            recordingTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.recordData), userInfo: nil, repeats: true)
            timeIsRunning = true
        }
    }
    
    @IBAction func stopTime(_ sender: Any) {
        if timeIsRunning {
            for timer in targetTimers {
                timer.invalidate()
            }
            durationTimer.invalidate()
            recordingTimer.invalidate()
            pauseTime = Date.timeIntervalSinceReferenceDate
            timeIsRunning = false
            
            timeIsPaused = true
            stopButton.isHidden = true
            stopButton.isEnabled = false
            endButton.isHidden = false
            endButton.isEnabled = true
            startButton.isEnabled = true
        }
    }
    
    @IBAction func endTime(_ sender: Any) {
        // invalidate all the timers
        for timer in targetTimers {
            timer.invalidate()
        }
        durationTimer.invalidate()
        recordingTimer.invalidate()
        
        endButton.isEnabled = false
        endButton.isHidden = true
        stopButton.isHidden = false
        rpeTime = Date.timeIntervalSinceReferenceDate
        endWorkout = true
        getRpe()
        customizeWorkoutButton.isHidden = false
        customizeWorkoutButton.isEnabled = true
    }
    @IBAction func manualRpeInput(_ sender: Any) {
        if !gettingRpe {
            gettingRpe = true
            
            // show the new screen over the current one; time will keep running, etc.
            self.performSegue(withIdentifier: "rpeSegue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.setTitleColor(UIColor.gray, for: UIControlState.disabled)
        stopButton.setTitleColor(UIColor.gray, for: UIControlState.disabled)
        startButton.isEnabled = false
        stopButton.isEnabled = false
        endButton.isEnabled = false
        endButton.isHidden = true
        inputRpeButton.isHidden = true
        inputRpeButton.isEnabled = false
        
        // listen for notifications from sensors and other views
        NotificationCenter.default.addObserver(self, selector: #selector(displayHeartRate), name: NSNotification.Name(rawValue: hrmNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayRSC), name: NSNotification.Name(rawValue: rscNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recordRpe), name: NSNotification.Name(rawValue: rpeNotification), object: nil)
        
        // set up notifications (code taken from https://www.hackingwithswift.com/read/21/2/scheduling-notifications-unusernotificationcenter-and-unnotificationrequest)
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
        // begin tracking location
        myLocationManager.delegate = myLocationDelegate
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.authorizedAlways {
            myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
            myLocationManager.distanceFilter = kCLDistanceFilterNone
            myLocationManager.startUpdatingLocation()
        }
        else if status == .notDetermined {
            myLocationManager.requestAlwaysAuthorization()
        }
        
        // begin scanning for the necessary devices with Bluetooth
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
        startButton.isEnabled = false
        endButton.isHidden = true
        endWorkout = false
        inputRpeButton.isHidden = true
        inputRpeButton.isEnabled = false
        customizeWorkoutButton.isHidden = false
        customizeWorkoutButton.isEnabled = true
    }
    
    // display a new heart rate
    func displayHeartRate() {
        if let heartRate = hrm {
            heartRateLabel.text = String(heartRate)
        }
    }
    
    // display data from the foot pod
    func displayRSC() {
        if let currentSpeedMetersPerSecond = currentSpeed {
            // convert to mile pace
            let milesPerSecond = currentSpeedMetersPerSecond / 1609.34
            if (milesPerSecond > 0) {
                let secondsPerMile = 1.0 / milesPerSecond
                let minutesValue = Int(secondsPerMile) / 60
                let secondsValue = Int(secondsPerMile) - (minutesValue * 60)
                speedLabel.text = "\(minutesValue):\(String(format:"%02d",secondsValue))"
            }
            //speedLabel.text = String(format: "%.2f", currentSpeedMetersPerSecond)
        }
        if let theCurrentCadence = currentCadence {
            cadenceLabel.text = String(theCurrentCadence)
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
        distance.append(currentTotalDistance)
        cadence.append(currentCadence)
        latitudes.append(currentLatitude)
        longitudes.append(currentLongitude)
        altitudes.append(currentAltitude)
        hrm = nil
        currentSpeed = nil
        currentTotalDistance = nil
        currentCadence = nil
    }
    
    // store RPE data for writing to file
    func recordRpe() {
        gettingRpe = false
        if let unwrappedRpe = currentRpe {
            if(endWorkout) {
                dateTime.append(rpeTime)
                rpe.append((rpeTime, unwrappedRpe))
            }
            else {
                let theTime = Date.timeIntervalSinceReferenceDate
                dateTime.append(theTime)
                rpe.append((theTime, unwrappedRpe))
            }
            
            heartRate.append(hrm)
            speed.append(currentSpeed)
            distance.append(currentTotalDistance)
            cadence.append(currentCadence)
            latitudes.append(currentLatitude)
            longitudes.append(currentLongitude)
            altitudes.append(currentAltitude)
            hrm = nil
            currentSpeed = nil
            currentTotalDistance = nil
            currentCadence = nil
        }
        if endWorkout {
            exportData()
        }
    }

    // write data to a file
    func exportData() {
        // since we want the user to access her/his file, store in Documents/
        // build a long, long string
        let gpxManager = GPXFileManager()
        let myFileContents = gpxManager.toGpx(dateArray: dateTime, heartRateArray: heartRate, speedArray: speed, distanceArray: distance, cadenceArray: cadence, latitudeArray: latitudes, longitudeArray: longitudes, altitudeArray: altitudes, rpeArray: rpe)
       /* var myFileContents2 = ""
        for i in 0...heartRate.count - 1 {
            if let theHeartRate = heartRate[i] {
                myFileContents2 = myFileContents2 + "\(theHeartRate)"
                if i < heartRate.count - 1 {
                    myFileContents2 = myFileContents2 + ", "
                }
            }
        }*/
        
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
                } catch {
                    // alert code modified from Brian Moakley's Beginning iOS 10 Part 1 Getting Started: Alerting the user https://videos.raywenderlich.com/courses/beginning-ios-10-part-1-getting-started/lessons/6
                    let alertController = UIAlertController(title: "BodyMonitor", message: "Save Failed", preferredStyle: .alert)
                    let actionItem = UIAlertAction(title: "Ok", style: .default)
                    alertController.addAction(actionItem)
                    present(alertController, animated: true, completion: nil)
                    print("Error creating user folder in documents dir: \(error)")
                }
            }
            
            // give the current file a timestamp
            let file = CACurrentMediaTime()
            // name the file with its extension
            let fileName = String(file) + ".gpx"
            /*let fileName2 = String(file) + ".csv"*/
            
            //write the file
            do{
                try myFileContents.write(toFile: userDirectoryPath.appending("/" + userName + fileName),atomically: true, encoding: String.Encoding.utf8 )
                /*try myFileContents2.write(toFile: userDirectoryPath.appending("/" + userName + fileName2),atomically: true, encoding: String.Encoding.utf8 )*/
                // alert code in try and catch statements modified from Brian Moakley's Beginning iOS 10 Part 1 Getting Started: Alerting the user https://videos.raywenderlich.com/courses/beginning-ios-10-part-1-getting-started/lessons/6
                let alertController = UIAlertController(title: "BodyMonitor", message: "Workout Saved!", preferredStyle: .alert)
                let actionItem = UIAlertAction(title: "Ok", style: .default)
                 alertController.addAction(actionItem)
                present(alertController, animated: true, completion: nil)
                } catch{
                let alertController = UIAlertController(title: "BodyMonitor", message: "Save Failed", preferredStyle: .alert)
                let actionItem = UIAlertAction(title: "Ok", style: .default)
                 alertController.addAction(actionItem)
                present(alertController, animated: true, completion: nil)
                }
            }
        reset()
    }
    
    // query for RPE
    func getRpe() {
        if !gettingRpe {
            gettingRpe = true
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            AudioServicesPlayAlertSound(SystemSoundID(1007))
            
            // add a notification (code from https://www.hackingwithswift.com/read/21/2/scheduling-notifications-unusernotificationcenter-and-unnotificationrequest)
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "RPE Interval Hit"
            content.body = "Enter RPE"
            content.categoryIdentifier = "alarm"
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
            
            // show the new screen over the current one; time will keep running, etc.
            self.performSegue(withIdentifier: "rpeSegue", sender: self)
        }
    }
}

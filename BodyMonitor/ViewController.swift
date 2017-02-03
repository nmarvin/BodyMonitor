//
//  ViewController.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 12/17/16.
//  Copyright © 2016 Nicole Marvin. All rights reserved.
//

import UIKit
import CoreBluetooth

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

// heart rate
var hrm: Int? = nil
var speed1: Int? = nil
var cadence1: Int? = nil
var strideLength1: Int? = nil
var totalDistance1: Int? = nil
var speed2: Int? = nil
var cadence2: Int? = nil
var strideLength2: Int? = nil
var totalDistance2: Int? = nil

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load")
        
        // listen for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(displayHeartRate), name: NSNotification.Name(rawValue: hrmNotification), object: nil)
 
        NotificationCenter.default.addObserver(self, selector: #selector(displayRSC1), name: NSNotification.Name(rawValue: rsc1Notification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayRSC2), name: NSNotification.Name(rawValue: rsc2Notification), object: nil)
        // begin scanning for the necessary devices
        if myManager.state == .poweredOn {
            myManager.scanForPeripherals(withServices: serviceUUIDS, options: nil)
        }
    }

    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var speed1Label: UILabel!
    @IBOutlet weak var cadence1Label: UILabel!
    @IBOutlet weak var distance1Label: UILabel!
    @IBOutlet weak var speed2Label: UILabel!
    @IBOutlet weak var cadence2Label: UILabel!
    @IBOutlet weak var distance2Label: UILabel!
    
    @IBAction func getStarted(_ sender: Any) {
        myManager.scanForPeripherals(withServices: serviceUUIDS, options: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        // practice putting in an alert (yes this works)
       /* let alertController = UIAlertController(title: "BodyMonitor", message: "App View Loaded", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Let's Get Started!", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)*/
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

}

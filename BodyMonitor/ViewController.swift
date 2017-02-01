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
let POLAR_STRIDE_SPEED_CADENCE_SERVICE_UUID = CBUUID(string: "1814")
let serviceUUIDS = [POLARH7_HRM_HEART_RATE_SERVICE_UUID, POLARH7_HRM_DEVICE_INFO_SERVICE_UUID, POLAR_STRIDE_SPEED_CADENCE_SERVICE_UUID]

// second: characteristic UUIDs
let POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID = CBUUID(string: "2A37")
let POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID = CBUUID(string: "2A29")
let POLAR_STRIDE_SPEED_CADENCE_MEASUREMENT_CHARACTERISTIC_UUID = CBUUID(string: "2A53")
let characteristicUUIDS = [POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID, POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID, POLAR_STRIDE_SPEED_CADENCE_MEASUREMENT_CHARACTERISTIC_UUID]

// get Bluetooth fired up
let myManagerDelegate = MyCentralManagerDelegate()
let myManager = CBCentralManager(delegate: myManagerDelegate, queue: nil)

// notification messages
let hrmNotification = "Heart Rate Updated"

// heart rate
var hrm: Int? = nil

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load")
        
        // listen for heart rate notifications
        NotificationCenter.default.addObserver(self, selector: #selector(displayHeartRate), name: NSNotification.Name(rawValue: hrmNotification), object: nil)
 
        // begin scanning for the necessary devices
        if myManager.state == .poweredOn {
            myManager.scanForPeripherals(withServices: serviceUUIDS, options: nil)
        }
    }

    @IBOutlet weak var heartRateLabel: UILabel!
    
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


}


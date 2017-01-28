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
let serviceUUIDS = [POLARH7_HRM_HEART_RATE_SERVICE_UUID, POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]

// second: characteristic UUIDs
let POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID = CBUUID(string: "2A37")
let POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID = CBUUID(string: "2A29")

// get Bluetooth fired up
let myManagerDelegate = MyCentralManagerDelegate()
let myManager = CBCentralManager(delegate: myManagerDelegate, queue: nil)

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load")
        // begin scanning for the necessary devices
        myManager.scanForPeripherals(withServices: serviceUUIDS, options: nil)
        
    }

    @IBAction func getStarted(_ sender: Any) {
        print("Starting!")
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


}


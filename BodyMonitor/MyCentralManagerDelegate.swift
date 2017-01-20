//
//  MyCentralManagerDelegate.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 12/17/16.
//  Copyright © 2016 Nicole Marvin. All rights reserved.
//

import CoreBluetooth
import UIKit

// global variables based off BLE specifications
// first: service UUIDS
let POLARH7_HRM_DEVICE_INFO_SERVICE_UUID = "180A"
let POLARH7_HRM_HEART_RATE_SERVICE_UUID = "180D"

// second: characteristic UUIDs
let POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID = "2A37"
let POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID = "2A29"

extension CBCentralManager: CBCentralManagerDelegate {
//class MyCentralManagerDelegate: UIViewController, CBCentralManagerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertController = UIAlertController(title: "CentralManager View", message: "View Loaded!", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    var hrmServiceUUID = CBUUID(string: POLARH7_HRM_HEART_RATE_SERVICE_UUID)
    //var vc = ViewController()
    
   /* override init () {
        // initialize UUIDs
        //hrmServiceUUID = CBUUID(string: POLARH7_HRM_HEART_RATE_SERVICE_UUID)
        super.init()
    }*/
    // for now, log the state to the console
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state)
        {
        case.unsupported:
            print("BLE is not supported")
            let alertController = UIAlertController(title: "BodyMonitor", message: "BLE Unsupported", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Gotcha.", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        case.unauthorized
            :
            print("BLE is unauthorized")
        case.unknown:
            print("BLE is Unknown")
        case.resetting:
            print("BLE is Resetting")
        // TODO: eventually, this case should alert the user to turn on BLE
        case.poweredOff:
            print("BLE service is powered off")
        // when Bluetooth powers on, begin scanning for peripherals
        case.poweredOn:
            print("BLE service is powered on")
            // try an alert
            let alertController = UIAlertController(title: "BodyMonitor", message: "BlueTooth is On", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Hooray!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            let serviceUUIDS: [CBUUID] = [hrmServiceUUID]
            central.scanForPeripherals(withServices: serviceUUIDS, options: nil)
        }
    }
    
    // get information about a CBPeripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var g = advertisementData.makeIterator()
        while let s = g.next() {
            print(s.key)
        }
       /* let device = (advertisementData as NSDictionary)
            .object(forKey: CBAdvertisementDataLocalNameKey)
            as? NSString
        
        if device?.containsString() == true {
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connectPeripheral(peripheral, options: nil)*/
        
    }
    
    // runs when connected to a peripheral
    //func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
  //      <#code#>
  //  }
}

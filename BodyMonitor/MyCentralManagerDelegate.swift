//
//  MyCentralManagerDelegate.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 12/17/16.
//  Copyright © 2016 Nicole Marvin. All rights reserved.
//

import CoreBluetooth

// the peripherals we expect to connect to
var tempPeripheral: CBPeripheral!
var hrmPeripheral:CBPeripheral!
var podPeripheral1:CBPeripheral!
var podPeripheral2:CBPeripheral!

class MyCentralManagerDelegate: NSObject, CBCentralManagerDelegate {
    
    override init () {
        super.init()
        print("central manager initializing")
    }
    // for now, log the state to the console
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("State updated")
    switch (central.state)
        {
        case.unsupported:
            print("BLE is not supported")
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
            central.scanForPeripherals(withServices: serviceUUIDS, options: nil)
        }
    }
    
    // if a peripheral was discovered, connect to it (maybe later check what's already connected?)
    // this method called when scanForPeripheral() finds a peripheral
    func centralManager(_ central: CBCentralManager, didDiscover: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let id = String(describing: didDiscover.identifier)
        print("Identifier: ", id)
        print("Name: ", didDiscover.name)
        //let currentServices = didDiscover.services
        tempPeripheral = didDiscover
        tempPeripheral.delegate = MyPeripheralDelegate()
        central.connect(tempPeripheral, options: nil)
        /*if(currentServices?.contains(POLARH7_HRM_DEVICE_INFO_SERVICE_UUID)) {
        hrmPeripheral = didDiscover
        let peripheralDelegate = MyPeripheralDelegate()
        connectingPeripheral.delegate = peripheralDelegate
        central.connect(connectingPeripheral, options: nil)
        }*/
        

        if let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey)
            as? NSString
        {
        print("Device name : \(device)")
            // identify heart rate monitor
            if device.contains("Polar H7") {
                storePeripheral(tempPeripheral, isHeartSensor: true)
            }
        
            else if device.contains("") {
                storePeripheral(tempPeripheral, isHeartSensor: false)
            }
        }
        
        }
    
    // called by a CBCentralManager when it connects to a peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Successful Connection!")
        // identify and permanently store the peripheral
        //storePeripheral(tempPeripheral)
    }
    
    // called by a CBCentralManager when it disconnects from a peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let realError = error {
            print("Error: \(realError)")
        }
       /* if error != nil {
            print("Error message: \(error)".self)
        }*/
        else {
            print("disconnected from Peripheral")
        }
    }
    
    
    // runs when connected to a peripheral
    //func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    //      <#code#>
    //  }
    
    // permanently store a peripheral
    func storePeripheral(_ temporary: CBPeripheral, isHeartSensor:Bool) {
        if isHeartSensor {
            hrmPeripheral = tempPeripheral
        }
        else if podPeripheral1 == nil {
            podPeripheral1 = tempPeripheral
        }
        else if podPeripheral2 == nil {
            podPeripheral2 = tempPeripheral
        }
    }
    
    
        
    }
    


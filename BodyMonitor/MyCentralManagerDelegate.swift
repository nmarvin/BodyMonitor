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

// the peripheral delegate
let myPeripheralDelegate = MyPeripheralDelegate()

class MyCentralManagerDelegate: NSObject, CBCentralManagerDelegate {
    
    override init() {
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
            startScan(central)
        }
    }
    
    // if a peripheral was discovered, connect to it
    // this method called when scanForPeripheral() finds a peripheral
    func centralManager(_ central: CBCentralManager, didDiscover: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        central.stopScan()
        let id = String(describing: didDiscover.identifier)
        print("Identifier: ", id)
        print("Name: ", didDiscover.name)
        //let currentServices = didDiscover.services
        tempPeripheral = didDiscover
        tempPeripheral.delegate = myPeripheralDelegate
        //central.connect(tempPeripheral, options: nil)
        
        if let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey)
            as? NSString
        {
        print("Device name : \(device)")
            // identify heart rate monitor
            if device.contains("Polar H7") {
                if let permanentPeripheral = storePeripheral(tempPeripheral, isHeartSensor: true) {
                    central.connect(permanentPeripheral, options: nil)
                }
            }
        
            else if device.contains("Polar RUN") {
                if let permanentPeripheral = storePeripheral(tempPeripheral, isHeartSensor: false) {
                    central.connect(permanentPeripheral, options: nil)
                }
            }
        }
        if (hrmPeripheral == nil || podPeripheral1 == nil || podPeripheral2 == nil) {
            startScan(central)
        }
    }
    
    // called by a CBCentralManager when it connects to a peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Successful Connection!")
        peripheral.delegate = myPeripheralDelegate
        
        // get services and initiate data reading
        
       /* if let services = peripheral.services {
            print("peripheral has services")
            if services.count > 0 {
                for service in services {
                    peripheral.discoverCharacteristics(characteristicUUIDS, for: service)
                }
            }
        } else {print("no services available")} */
        
    }
    
    // called by a CBCentralManager when it disconnects from a peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let realError = error {
            print("Error: \(realError)")
        }
       
        else {
            print("disconnected from Peripheral")
        }
    }
    
    // start scanning for peripherals
    func startScan(_ central: CBCentralManager) {
        print("starting scan")
        central.scanForPeripherals(withServices: serviceUUIDS, options: nil)
    }
    
    // permanently store a peripheral
    func storePeripheral(_ temporary: CBPeripheral, isHeartSensor:Bool) -> CBPeripheral? {
        if isHeartSensor {
            print("This is the heart sensor.")
            hrmPeripheral = temporary
            return hrmPeripheral
        }
        else if podPeripheral1 == nil {
            print("This is the first stride sensor.")
            podPeripheral1 = temporary
            return podPeripheral1
        }
        else if podPeripheral2 == nil {
            podPeripheral2 = temporary
            return podPeripheral2
        }
        else {
            print("Something went wrong!")
            return nil
        }
    }
}
    


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

class MyCentralManagerDelegate: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    override init() {
        super.init()
    }
    // for now, log the state to the console
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
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
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        central.stopScan()
        let id = String(describing: peripheral.identifier)
        print("Identifier: ", id)
        print("Name: ", peripheral.name)
        //let currentServices = didDiscover.services
        tempPeripheral = peripheral
        tempPeripheral.delegate = myPeripheralDelegate
        //central.connect(tempPeripheral, options: nil)
        
        if let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey)
            as? String
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
        else {
            print("All three devices connected")
        }
    }
    
    // called by a CBCentralManager when it connects to a peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = myPeripheralDelegate
        peripheral.discoverServices(nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let realError = error {
            print("Error: \(realError)")
        }
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
        if (hrmPeripheral == nil || podPeripheral1 == nil || podPeripheral2 == nil) {
            central.scanForPeripherals(withServices: serviceUUIDS, options: nil)
        }
    }
    
    // permanently store a peripheral
    func storePeripheral(_ temporary: CBPeripheral, isHeartSensor:Bool) -> CBPeripheral? {
        if isHeartSensor {
            hrmPeripheral = temporary
            return hrmPeripheral
        }
        else if podPeripheral1 == nil {
            podPeripheral1 = temporary
            return podPeripheral1
        }
        else if podPeripheral2 == nil {
            podPeripheral2 = temporary
            return podPeripheral2
        }
        else {
            return nil
        }
    }
}

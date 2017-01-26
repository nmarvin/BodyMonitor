//
//  MyCentralManagerDelegate.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 12/17/16.
//  Copyright © 2016 Nicole Marvin. All rights reserved.
//

import CoreBluetooth


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
        let connectingPeripheral = didDiscover
        let peripheralDelegate = MyPeripheralDelegate()
        connectingPeripheral.delegate = peripheralDelegate
        central.connect(connectingPeripheral, options: nil)
        print("just attempted connecting")
        }
    
    // runs when connected to a peripheral
    //func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    //      <#code#>
    //  }
        
    }
    


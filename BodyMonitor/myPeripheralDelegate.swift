//
//  myPeripheralDelegate.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 1/21/17.
//  Copyright © 2017 Nicole Marvin. All rights reserved.
//

import CoreBluetooth

class MyPeripheralDelegate: NSObject, CBPeripheralDelegate {
    override init () {
        super.init()
        print("peripheral manager initializing")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print()
    }
    
}

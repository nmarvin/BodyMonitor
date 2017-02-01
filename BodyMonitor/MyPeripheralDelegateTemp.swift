//
//  myPeripheralDelegate.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 1/21/17.
//  Copyright © 2017 Nicole Marvin. All rights reserved.
//

import CoreBluetooth

class MyPeripheralDelegate: NSObject, CBPeripheralDelegate {
    override init() {
        super.init()
        print("peripheral manager initializing")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("services discovered")
        if let realError = error {
            print("error: \(realError)")
        }
        if let services = peripheral.services {
            if services.count > 0 {
                for service in services {
                    peripheral.discoverCharacteristics(characteristicUUIDS, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        print("included services discovered")
    }
    
    // get notifications from desired characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // look if there is a HRM characteristic and subscribe
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid.isEqual(POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if (peripheral == hrmPeripheral) {
            print("Subscribed to HRM")
        }
    }
    
    // respond to receiving new data from peripheral
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // check for error
        if let theError = error {
            print("Error: \(theError)")
        }
        else if peripheral == hrmPeripheral && characteristic.uuid == POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID {
            var heartRateData = characteristic.value
            
            if let currentHeartRate = heartRateData {
                
                // do some low-level stuff to convert the bits into a heart rate measurement
                var buffer = [UInt8](repeating: 0x0, count: currentHeartRate.count)
                currentHeartRate.copyBytes(to: &buffer, count:buffer.count)
                
                // check first bit of the buffer. if 0, the heart rate is UInt8; otherwise, it's UInt16
                if buffer[0] & 0x01 == 0 {
                    hrm = Int(buffer[1]);
                }
                else {
                    hrm = Int(buffer[1] << 8)
                }
                print("displaying heart rate!")
                // send a notification that new data is avaialble
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: hrmNotification), object: nil)
            }
        }
    }
}

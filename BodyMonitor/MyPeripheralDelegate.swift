//
//  MyPeripheralDelegate.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 1/21/17.
//  Copyright © 2017 Nicole Marvin. All rights reserved.
//

import CoreBluetooth

class MyPeripheralDelegate: NSObject, CBPeripheralDelegate {
    override init() {
        super.init()
    }
    
    // called when a peripheral's services are discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let realError = error {
            print("error: \(realError)")
        }
        print("services discovered")
        if let services = peripheral.services {
            if services.count > 0 {
                for service in services {
                    peripheral.discoverCharacteristics(characteristicUUIDS, for: service)
                }
            }
        }
    }
    
    // get notifications from desired characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // look for the characteristics of interest and subsctibe
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid.isEqual(POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                else if characteristic.uuid.isEqual(POLAR_STRIDE_RSC_MEASUREMENT_CHARACTERISTIC_UUID) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if (hrmPeripheral != nil) {
            if (peripheral == hrmPeripheral) {
                print("Subscribed to HRM")
            }
        }
    }
    
    // respond to receiving new data from peripheral
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // check for error
        if let theError = error {
            print("Error: \(theError)")
        }
        else if peripheral == hrmPeripheral && characteristic.uuid == POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID {
            if let currentHeartRate = characteristic.value {
                getHeartRateData(currentHeartRate)
            }
        }
        
        else if characteristic.uuid == POLAR_STRIDE_RSC_MEASUREMENT_CHARACTERISTIC_UUID {
            if let currentRsc = characteristic.value {
                getRscData(peripheral, currentRsc)
            }
            
        }
        
        else if characteristic.uuid == POLAR_STRIDE_RSC_FEATURE_CHARACTERISTIC_UUID {
            // bits: 0 - instantaneous stride length supported; 1 - total distance supported; 2 - walk/run status supported; 3 - calibration supported; 4 - multiple locations supported
            if let currentRscFeature = characteristic.value {
                getRscFeatureData(currentRscFeature)
            }
            
        }
    }
    
    func getHeartRateData(_ currentHeartRate: Data) {
        
        // do some low-level stuff to convert the bits into a heart rate measurement
        var buffer = [UInt8](repeating: 0x0, count: currentHeartRate.count)
        currentHeartRate.copyBytes(to: &buffer, count:buffer.count)
        
        // check first bit of the buffer. if 0, the heart rate is UInt8; otherwise, it's UInt16
        if buffer[0] & 0b00000001 == 0 {
            hrm = Int(buffer[1]);
        }else {
            hrm = Int(buffer[1] << 8)
        }
        // send a notification that new data is avaialble
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: hrmNotification), object: nil)
        
    }
    
    func getRscData(_ peripheral: CBPeripheral, _ currentRsc: Data) {
        // bits: 0 - instantaneous stride length present; 1 - total distance present; 2 - 0 for walk; 1 for run
        // convert bits into speed and cadence
        var buffer = [UInt8](repeating: 0x0, count: currentRsc.count)
        currentRsc.copyBytes(to: &buffer, count: buffer.count)
        
        // get speed: UInt16
        var currentSpeed = (Int(buffer[2]) << 8) + Int(buffer[1])
        
        // get cadence: UInt8
        var currentCadence = Int(buffer[3])
        
        var currentStrideLength: Int? = nil
        var totalDistance: Int? = nil
        
        // get instantaneous stride length and total distance
        if (buffer[0] & 0b00000001 == 1) {
            if buffer.count >= 4 {
                currentStrideLength = (Int(buffer[4]) << 8) + Int(buffer[3])
            }
            if (buffer[0] & 0b00000010 == 1) {
                if buffer.count >= 8 {
                    totalDistance = (Int(buffer[8]) << 24) + (Int(buffer[7]) << 16) + (Int(buffer[6]) << 8) + Int(buffer[5])
                }
            }
        }
        else if (buffer[0] & 0b00000010 == 1) {
            if buffer.count >= 6 {
                totalDistance = (Int(buffer[6]) << 24) + (Int(buffer[5]) << 16) + (Int(buffer[4]) << 8) + Int(buffer[3])
            }
        }
        
        if peripheral == podPeripheral1 {
            speed1 = currentSpeed
            cadence1 = currentCadence
            if let stride1 = currentStrideLength {
                strideLength1 = stride1
            }
            if let distance1 = totalDistance {
                totalDistance1 = distance1
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: rsc1Notification), object: nil)
            
        } else if peripheral == podPeripheral2 {
            speed2 = currentSpeed
            cadence2 = currentCadence
            if let stride2 = currentStrideLength {
                strideLength2 = stride2
            }
            if let distance2 = totalDistance {
                totalDistance2 = distance2
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: rsc2Notification), object: nil)
        }

    }
    
    func getRscFeatureData(_ currentRscFeature: Data) {
        var buffer = [UInt8](repeating: 0x0, count: 9)
        var currentStrideLength = 0
        var totalDistance = 0
        if (buffer[0] & 0b00000001 == 1) {
            if buffer.count >= 4 {
                currentStrideLength = (Int(buffer[4]) << 8) + Int(buffer[3])
            }
            if (buffer[0] & 0b00000010 == 1) {
                if buffer.count >= 8 {
                    totalDistance = Int(buffer[8] << 24) + (Int(buffer[7]) << 16) + (Int(buffer[6]) << 8) + Int(buffer[5])
                }
            }
        }
        else if (buffer[0] & 0b00000010 == 1) {
            if buffer.count >= 6 {
                totalDistance = (Int(buffer[6]) << 24) + (Int(buffer[5]) << 16) + (Int(buffer[4]) << 8) + Int(buffer[3])
            }
        }

    }
}

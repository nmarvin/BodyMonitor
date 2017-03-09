//
//  MyPeripheralDelegate.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 1/21/17.
//  Copyright © 2017 Nicole Marvin. All rights reserved.
//

import CoreBluetooth

class MyPeripheralDelegate: NSObject, CBPeripheralDelegate {
    
    var distanceSupported: Bool = false
    var walkRunStatusSupported: Bool = false
    var calibrationSupported: Bool = false
    
    override init() {
        super.init()
        
    }
    
    // called when a peripheral's services are discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
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
    
    // respond to receiving new data from peripheral
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // check for error
        if let theError = error {
            print("Error: \(theError)")
        }
        else if peripheral === hrmPeripheral && characteristic.uuid == POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID {
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
                getRscFeatureData(peripheral, currentRscFeature)
            }
            
        }
    }
    
    func getHeartRateData(_ currentHeartRate: Data) {
        
        // do some low-level stuff to convert the bits into a heart rate measurement
        var buffer = [UInt8](repeating: 0x0, count: currentHeartRate.count)
        currentHeartRate.copyBytes(to: &buffer, count:buffer.count)
        
        // check first bit of the buffer. if 0, the heart rate is UInt8; otherwise, it's UInt16
        if buffer[0] & 0b00000001 == 0 {
            hrm = buffer[1]
        }else {
            hrm = nil
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
        var myCurrentSpeed = Double((Int(buffer[2]) << 8) + Int(buffer[1]))
        
        // get cadence: UInt8
        var myCurrentCadence = buffer[3]
        
        var myCurrentStrideLength: Double? = nil
        var myTotalDistance: Double? = nil
        
        // get instantaneous stride length and total distance
        if (buffer[0] & 0b00000001 == 1) {
            if buffer.count >= 4 {
                var myStrideLength = Int(buffer[4]) << 8 + Int(buffer[3])
                myCurrentStrideLength = Double(myStrideLength)
            }
            if (buffer[0] & 0b00000010 == 1) {
                if buffer.count >= 9 {
                    let theDistance = Int(buffer[8]) << 24 + (Int(buffer[7]) << 16) + (Int(buffer[6]) << 8) + Int(buffer[5])
                    myTotalDistance = Double(theDistance)
                }
            }
        }
        else if (buffer[0] & 0b00000010 == 1) {
            if buffer.count >= 7 {
                let theDistance = Int(buffer[6]) << 24 + (Int(buffer[5]) << 16) + (Int(buffer[4]) << 8) + Int(buffer[3])
                myTotalDistance = Double(theDistance)
            }
        }
        
        if peripheral == podPeripheral {
            currentSpeed = myCurrentSpeed
            currentCadence = myCurrentCadence
            if let stride1 = myCurrentStrideLength {
                currentStrideLength = stride1
            }
            if let distance1 = myTotalDistance {
                print("Distance: \(distance1)")
                currentTotalDistance = distance1
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: rscNotification), object: nil)
            
        }
    }
    
    func getRscFeatureData(_ peripheral: CBPeripheral, _ currentRscFeature: Data) {
        
        if peripheral == podPeripheral {

            // check if total distance supported
            if (currentRscFeature[0] & 0b00000010 == 1) {
                distanceSupported = true
            }
            if (currentRscFeature[0] & 0b00000100 == 1) {
                walkRunStatusSupported = true
            }
            if (currentRscFeature[0] & 0b00001000 == 1) {
                calibrationSupported = true
            }
        }
    }
}

//
//  GPXFileManager.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 2/9/17.
//  Copyright © 2017 Nicole Marvin. All rights reserved.
//

import Foundation

class GPXFileManager {
    
    func toGpx(dateArray: [TimeInterval], heartRateArray: [UInt8?], speedArray: [Double?], distanceArray: [Double?], cadenceArray: [UInt8?], latitudeArray: [Double?], longitudeArray: [Double?], altitudeArray: [Double?], rpeArray: [(TimeInterval, Int)]) -> String {
        let tab = "  "
        let headerString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<gpx creator=\"BodyMonitor\"\n" + tab + "xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/11.xsd\"\n" + tab + "xmlns:ns2=\"http://www.garmin.com/xmlschemas/TrackPointExtension/v1\"\n" + tab + "xmlns:ns3=\"http://www.cluetrust.com/Schemas/gpxdata10.xsd\"\n" + tab + "xmlns:ns4=\"BodyMonitorSpec\"\n" + tab + tab + "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
        
        // format the start time
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.Z"
        dateFormatter.timeZone = NSTimeZone.local
        let lapStartTime = dateFormatter.string(from: Date.init(timeIntervalSinceReferenceDate:dateArray[0]))
        
        let metaData = "\n" + tab + "<metadata>\n" + tab + tab + "<text>BodyMonitor</text>\n" + tab + tab + "<time>" + lapStartTime + "</time>\n" + tab + "</metadata>"
        
        // start the track seg
        let startSeg = "\n" + tab + "<trk>\n" + tab + tab + "<type>running</type>\n"  + tab + tab + "<trkseg>"
        
        // a string for the file contents
        var gpxData = headerString + metaData + startSeg
        // the number of tabs to insert before points
        let tabDepth = 3
    
        var currentIndexRpe = 0
        var theRpe = rpeArray[currentIndexRpe]
        let length = dateArray.count - 1
        for i in 0...length {
            // check if this timePoint corresponds to the time of an RPE recording
            if dateArray[i] == theRpe.0 {
                gpxData = gpxData + createRpePoint(time: dateArray[i], heartRate: heartRateArray[i], speed: speedArray[i], distance: distanceArray[i], cadence: cadenceArray[i], latitude: latitudeArray[i], longitude: longitudeArray[i], altitude: altitudeArray[i], rpe: theRpe.1, tabDepth: tabDepth, tab: tab)
                
                // update the RPE point
                currentIndexRpe += 1
                if currentIndexRpe < rpeArray.count {
                    theRpe = rpeArray[currentIndexRpe]
                }
            }
            // record a timePoint without RPE
            else {
                gpxData = gpxData + createTrackPoint(time: dateArray[i], heartRate: heartRateArray[i], speed: speedArray[i], distance: distanceArray[i], cadence: cadenceArray[i], latitude: latitudeArray[i], longitude: longitudeArray[i], altitude: altitudeArray[i], tabDepth: tabDepth, tab: tab)
            }
        }
        // end the file
        let closingTags = "\n" + tab + tab + "</trkseg>\n" + tab + "</trk>\n</gpx>"
        return gpxData + closingTags
    }
    
    private func createTrackPoint(time: TimeInterval, heartRate: UInt8?, speed: Double?, distance: Double?, cadence: UInt8?, latitude: Double?, longitude: Double?, altitude: Double?, tabDepth: Int, tab: String) -> String {
        var localTabDepth = tabDepth
        var trkPoint = "\n"
        if let theLatitude = latitude, let theLongitude = longitude {
            trkPoint = addTabs(trkPoint, tab, localTabDepth) + "<trkpt lat=\"\(theLatitude)\"\n"
            trkPoint = addTabs(trkPoint, tab, localTabDepth+1) + "lon=\"\(theLongitude)\">"
        }
        else {
            return ""
        }
        localTabDepth = localTabDepth + 1
        // add altitude
        if let theAltitude = altitude {
            trkPoint = trkPoint + "\n"
            trkPoint = addTabs(trkPoint, tab, localTabDepth) + "<ele>\(theAltitude)</ele>"
        }
        
        // add Time
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.Z"
        dateFormatter.timeZone = NSTimeZone.local
        let theTime = dateFormatter.string(from: Date.init(timeIntervalSinceReferenceDate:time))
        trkPoint = trkPoint + "\n"
        trkPoint = addTabs(trkPoint, tab, localTabDepth)
        trkPoint = trkPoint + "<time>" + theTime + "</time>"
        
        // add DistanceMeters
        if let theDistance = distance {
            trkPoint = trkPoint + "\n"
            trkPoint = trkPoint + addTabs(trkPoint, tab, localTabDepth)
            trkPoint = trkPoint + "<DistanceMeters>" + String(theDistance) + "</DistanceMeters>"
        }
        // add extensions
        var extensionsPresent = false
        if (heartRate != nil || cadence != nil) {
            extensionsPresent = true
            trkPoint = trkPoint + "\n"
            trkPoint = addTabs(trkPoint, tab, localTabDepth)
            localTabDepth = localTabDepth + 1
            trkPoint = trkPoint + "<extensions>"
        
            trkPoint = trkPoint + "\n"
            trkPoint = addTabs(trkPoint, tab, localTabDepth)
            trkPoint = trkPoint + "<ns2:TrackPointExtension>"
            localTabDepth = localTabDepth + 1
        }
        
        // add HeartRateBpm
        if let theHeartRate = heartRate {
            trkPoint = trkPoint + "\n"
            trkPoint = addTabs(trkPoint, tab, localTabDepth)
            trkPoint = trkPoint + "<ns2:hr>" + String(theHeartRate) + "</ns2:hr>"
        }
        // add Cadence
        if let theCadence = cadence {
            trkPoint = trkPoint + "\n"
            trkPoint = addTabs(trkPoint, tab, localTabDepth)
            trkPoint = trkPoint + "<ns2:cad>" + String(theCadence) + "</ns2:cad>"
        }
        if extensionsPresent {
            localTabDepth = localTabDepth - 1
            trkPoint = trkPoint + "\n"
            trkPoint = addTabs(trkPoint, tab, localTabDepth)
            trkPoint = trkPoint + "</ns2:TrackPointExtension>"
        }
        // add speed
        if let theSpeed = speed {
            trkPoint = trkPoint + "\n"
            trkPoint = addTabs(trkPoint, tab, localTabDepth)
            trkPoint = trkPoint + "<ns4:TrackPointExtension>"
            localTabDepth = localTabDepth + 1
            
            trkPoint = trkPoint + "\n"
            trkPoint = addTabs(trkPoint, tab, localTabDepth)
            trkPoint = trkPoint + "<ns4:speed>" + String(theSpeed) + "</ns4:speed>"
            localTabDepth = localTabDepth - 1
            
            trkPoint = trkPoint + "\n"
            trkPoint = addTabs(trkPoint, tab, localTabDepth)
            trkPoint = trkPoint + "</ns4:TrackPointExtension>"
        }
        
        localTabDepth = localTabDepth - 1
        trkPoint = trkPoint + "\n"
        trkPoint = addTabs(trkPoint, tab, localTabDepth)
        trkPoint = trkPoint + "</extensions>"
        localTabDepth = localTabDepth - 1
        
        trkPoint = trkPoint + "\n"
        trkPoint = addTabs(trkPoint, tab, localTabDepth)
        trkPoint = trkPoint + "</trkpt>"
        
        return trkPoint
    }
    
    private func createRpePoint(time: TimeInterval, heartRate: UInt8?, speed: Double?, distance: Double?, cadence: UInt8?, latitude: Double?, longitude: Double?, altitude: Double?, rpe: Int, tabDepth: Int, tab: String) -> String {
        var localTabDepth = tabDepth
        var rpePoint = "\n"
        if let theLatitude = latitude, let theLongitude = longitude {
            rpePoint = addTabs(rpePoint, tab, localTabDepth) + "<trkpt lat=\"\(theLatitude)\"\n"
            rpePoint = addTabs(rpePoint, tab, localTabDepth+1) + "lon=\"\(theLongitude)\">"
        }
        else {
            return ""
        }
        localTabDepth = localTabDepth + 1
        // add altitude
        if let theAltitude = altitude {
            rpePoint = rpePoint + "\n"
            rpePoint = addTabs(rpePoint, tab, localTabDepth) + "<ele>\(theAltitude)</ele>"
        }
        
        // add Time
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.Z"
        dateFormatter.timeZone = NSTimeZone.local
        let theTime = dateFormatter.string(from: Date.init(timeIntervalSinceReferenceDate:time))
        rpePoint = rpePoint + "\n"
        rpePoint = addTabs(rpePoint, tab, localTabDepth)
        rpePoint = rpePoint + "<time>" + theTime + "</time>"
        
        // add DistanceMeters
        if let theDistance = distance {
            rpePoint = rpePoint + "\n"
            rpePoint = addTabs(rpePoint, tab, localTabDepth)
            rpePoint = rpePoint + "<DistanceMeters>" + String(theDistance) + "</DistanceMeters>"
        }
        // add extensions
        var extensionsPresent = false
        if (heartRate != nil || cadence != nil) {
            extensionsPresent = true
            rpePoint = rpePoint + "\n"
            rpePoint = addTabs(rpePoint, tab, localTabDepth)
            localTabDepth = localTabDepth + 1
            rpePoint = rpePoint + "<extensions>"
        
            rpePoint = rpePoint + "\n"
            rpePoint = addTabs(rpePoint, tab, localTabDepth)
            rpePoint = rpePoint + "<ns2:TrackPointExtension>"
            localTabDepth = localTabDepth + 1
        }
        
        // add HeartRateBpm
        if let theHeartRate = heartRate {
            rpePoint = rpePoint + "\n"
            rpePoint = addTabs(rpePoint, tab, localTabDepth)
            rpePoint = rpePoint + "<ns2:hr>" + String(theHeartRate) + "</ns2:hr>"
        }
        // add Cadence
        if let theCadence = cadence {
            rpePoint = rpePoint + "\n"
            rpePoint = addTabs(rpePoint, tab, localTabDepth)
            rpePoint = rpePoint + "<ns2:cad>" + String(theCadence) + "</ns2:cad>"
        }
        
        if extensionsPresent {
            localTabDepth = localTabDepth - 1
            rpePoint = rpePoint + "\n"
            rpePoint = addTabs(rpePoint, tab, localTabDepth)
            rpePoint = rpePoint + "</ns2:TrackPointExtension>"
        }
        else {
            rpePoint = rpePoint + "\n"
            rpePoint = addTabs(rpePoint, tab, localTabDepth)
            localTabDepth = localTabDepth + 1
            rpePoint = rpePoint + "<extensions>"
        }
        
        // add speed and RPE
        rpePoint = rpePoint + "\n"
        rpePoint = addTabs(rpePoint, tab, localTabDepth)
        rpePoint = rpePoint + "<ns4:TrackPointExtension>"
        localTabDepth = localTabDepth + 1
        
        if let theSpeed = speed {
            rpePoint = rpePoint + "\n"
            rpePoint = addTabs(rpePoint, tab, localTabDepth)
            rpePoint = rpePoint + "<ns4:speed>" + String(theSpeed) + "</ns4:speed>"
        }
        
        rpePoint = rpePoint + "\n"
        rpePoint = addTabs(rpePoint, tab, localTabDepth)
        rpePoint = rpePoint + "<ns4:rpe>" + String(rpe) + "</ns4:rpe>"
        localTabDepth = localTabDepth - 1
        
        rpePoint = rpePoint + "\n"
        rpePoint = addTabs(rpePoint, tab, localTabDepth)
        rpePoint = rpePoint + "</ns4:TrackPointExtension>"
        localTabDepth = localTabDepth - 1
        
        rpePoint = rpePoint + "\n"
        rpePoint = addTabs(rpePoint, tab, localTabDepth)
        rpePoint = rpePoint + "</extensions>"
        localTabDepth = localTabDepth - 1
        
        rpePoint = rpePoint + "\n"
        rpePoint = addTabs(rpePoint, tab, localTabDepth)
        rpePoint = rpePoint + "</trkpt>"
        
        return rpePoint
    }
    
    private func addTabs(_ s: String, _ tab: String, _ tabs: Int) -> String {
        var newString = s
        for _ in 1...tabs {
            newString = newString + tab
        }
        
        return newString
    }
}

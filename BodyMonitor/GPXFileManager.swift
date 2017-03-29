//
//  GPXFileManager.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 2/9/17.
//  Copyright © 2017 Nicole Marvin. All rights reserved.
//

import Foundation

class GPXFileManager {
    
    func toGpx(dateArray: [TimeInterval], heartRateArray: [UInt8?], speedArray: [Double?], distanceArray: [Double?], cadenceArray: [UInt8?], rpeArray: [(TimeInterval, Int)]) -> String {
        let tab = "  "
        let headerString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<gpx creator=\"BodyMonitor\"\n" + tab + "xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/11.xsd\"\n" + tab + "xmlns:ns2=\"http://www.garmin.com/xmlschemas/TrackPointExtension/v1\"\n" + tab + "xmlns:ns3=\"http://www.cluetrust.com/Schemas/gpxdata10.xsd\"\n" + tab + "xmlns:ns4=\"BodyMonitorRpeSpec\"\n" + tab + tab + "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
        
        // format the start time
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let lapStartTime = dateFormatter.string(from: Date.init(timeIntervalSinceReferenceDate:dateArray[0]))
        
        let metaData = "\n" + tab + "<metadata>\n" + tab + tab + "<text><BodyMonitor></text>\n" + tab + tab + "<time>" + lapStartTime + "</time>\n" + tab + "</metadata>"
        
        let totalTimeSeconds = "0"
        // calculate total time in seconds--make sure to account for paused time
        
        // determine total distance based on final distance point
        var totalDistance = "0.0"
        for instantaneousDistance in distanceArray.reversed() {
            if let theDistance = instantaneousDistance {
                totalDistance = String(theDistance)
                break
            }
        }
        // find maximum instantaneous speed
        var maximumSpeed = 0.0
        for currentSpeed in speedArray {
            if let theSpeed = currentSpeed {
                if theSpeed > maximumSpeed {
                    maximumSpeed = theSpeed
                }
            }
        }
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
                gpxData = gpxData + createRpePoint(time: dateArray[i], heartRate: heartRateArray[i], speed: speedArray[i], distance: distanceArray[i], cadence: cadenceArray[i], rpe: theRpe.1, tabDepth: tabDepth, tab: tab)
                
                // update the RPE point
                currentIndexRpe += 1
                if currentIndexRpe < rpeArray.count {
                    theRpe = rpeArray[currentIndexRpe]
                }
            }
            // record a timePoint without RPE
            else {
                gpxData = gpxData + createTrackPoint(time: dateArray[i], heartRate: heartRateArray[i], speed: speedArray[i], distance: distanceArray[i], cadence: cadenceArray[i], tabDepth: tabDepth, tab: tab)
            }
        }
        // end the file
        let closingTags = "\n" + tab + tab + "</trkseg>\n" + tab + "</trk>\n</gpx>"
        return gpxData + closingTags
    }
    
    private func createTrackPoint(time: TimeInterval, heartRate: UInt8?, speed: Double?, distance: Double?, cadence: UInt8?, tabDepth: Int, tab: String) -> String {
        var localTabDepth = tabDepth
        var trkPoint = "\n"
        trkPoint = addTabs(trkPoint, tab, localTabDepth) + "<trkpt>"
        
        // add Time
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let theTime = dateFormatter.string(from: Date.init(timeIntervalSinceReferenceDate:time))
        trkPoint = trkPoint + "\n"
        trkPoint = addTabs(trkPoint, tab, localTabDepth)
        trkPoint = trkPoint + "<time>" + theTime + "</time>"
        
        // add DistanceMeters
        if let theDistance = distance {
            trkPoint = trkPoint + "\n"
            trkPoint = trkPoint + addTabs(trkPoint, tab, localTabDepth)
            /*for _ in 1...localTabDepth {
             trkPoint = trkPoint + tab
             }*/
            trkPoint = trkPoint + "<DistanceMeters>" + String(theDistance) + "</DistanceMeters>"
        }
        // add extensions
        if (heartRate != nil || cadence != nil) {
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
        
        localTabDepth = localTabDepth - 1
        trkPoint = trkPoint + "\n"
        trkPoint = addTabs(trkPoint, tab, localTabDepth)
        trkPoint = trkPoint + "</ns2:TrackPointExtension>"
        
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
    
    private func createRpePoint(time: TimeInterval, heartRate: UInt8?, speed: Double?, distance: Double?, cadence: UInt8?, rpe: Int, tabDepth: Int, tab: String) -> String {
        var localTabDepth = tabDepth
        var rpePoint = "\n"
        rpePoint = addTabs(rpePoint, tab, localTabDepth) + "<trkpt>"
        
        // add Time
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
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
        rpePoint = rpePoint + "\n"
        rpePoint = addTabs(rpePoint, tab, localTabDepth)
        localTabDepth = localTabDepth + 1
        rpePoint = rpePoint + "<extensions>"
        
        rpePoint = rpePoint + "\n"
        rpePoint = addTabs(rpePoint, tab, localTabDepth)
        rpePoint = rpePoint + "<ns2:TrackPointExtension>"
        localTabDepth = localTabDepth + 1
        
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
        
        localTabDepth = localTabDepth - 1
        rpePoint = rpePoint + "\n"
        rpePoint = addTabs(rpePoint, tab, localTabDepth)
        rpePoint = rpePoint + "</ns2:TrackPointExtension>"
        
        // add RPE
        rpePoint = rpePoint + "\n"
        rpePoint = addTabs(rpePoint, tab, localTabDepth)
        rpePoint = rpePoint + "<ns4:TrackPointExtension>"
        localTabDepth = localTabDepth + 1
        
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

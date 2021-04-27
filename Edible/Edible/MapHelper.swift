//
//  MapHelper.swift
//  Edible

import Foundation
import Firebase
import CoreLocation
import MapKit

class MapHelper {
    
    // returns the distance of the passed in lattitude and longitude from the user's current location
    static func findDistanceFromCurrentLocation(lat: String, long: String, currentLocation: CLLocation) -> CLLocationDistance? {
    
        let destinationLocation = CLLocation(
            latitude:  (lat as NSString).doubleValue,
            longitude: (long as NSString).doubleValue
        )
        return currentLocation.distance(from: destinationLocation)

    }
}

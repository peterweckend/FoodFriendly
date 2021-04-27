//
//  RatingModel.swift
//  Edible

import Foundation
import Firebase

class RatingModel {
    
    var key: String
    var isFoodGoodPosCount: Int
    var isAtmosphereGoodPosCount: Int
    var isEdibilityGoodPosCount: Int
    var isFoodGoodTotalCount: Int
    var isAtmosphereGoodTotalCount: Int
    var isEdibilityGoodTotalCount: Int
    let ref: DatabaseReference?
    
    
    init?(isFoodGoodPosCount: Int, isAtmosphereGoodPosCount: Int, isEdibilityGoodPosCount: Int, isFoodGoodTotalCount: Int, isAtmosphereGoodTotalCount: Int, isEdibilityGoodTotalCount: Int, key: String = "") {
        self.key = key
        self.isFoodGoodPosCount = isFoodGoodPosCount
        self.isAtmosphereGoodPosCount = isAtmosphereGoodPosCount
        self.isEdibilityGoodPosCount = isEdibilityGoodPosCount
        self.isFoodGoodTotalCount = isFoodGoodTotalCount
        self.isAtmosphereGoodTotalCount = isAtmosphereGoodTotalCount
        self.isEdibilityGoodTotalCount = isEdibilityGoodTotalCount
        self.ref = nil
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "isFoodGoodPosCount": isFoodGoodPosCount,
            "isAtmosphereGoodPosCount": isAtmosphereGoodPosCount,
            "isEdibilityGoodPosCount": isEdibilityGoodPosCount,
            "isFoodGoodTotalCount": isFoodGoodTotalCount,
            "isAtmosphereGoodTotalCount": isAtmosphereGoodTotalCount,
            "isEdibilityGoodTotalCount": isEdibilityGoodTotalCount
            ] as NSDictionary
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        isFoodGoodPosCount = snapshotValue["isFoodGoodPosCount"] as! Int
        isAtmosphereGoodPosCount = snapshotValue["isAtmosphereGoodPosCount"] as! Int
        isEdibilityGoodPosCount = snapshotValue["isEdibilityGoodPosCount"] as! Int
        isFoodGoodTotalCount = snapshotValue["isFoodGoodTotalCount"] as! Int
        isAtmosphereGoodTotalCount = snapshotValue["isAtmosphereGoodTotalCount"] as! Int
        isEdibilityGoodTotalCount = snapshotValue["isEdibilityGoodTotalCount"] as! Int
        ref = snapshot.ref
        
    }
    
    // create an empty RatingModel
    init() {
        key = ""
        self.isFoodGoodPosCount = 0
        self.isAtmosphereGoodPosCount = 0
        self.isEdibilityGoodPosCount = 0
        self.isFoodGoodTotalCount = 0
        self.isAtmosphereGoodTotalCount = 0
        self.isEdibilityGoodTotalCount = 0
        self.ref = nil
    }
}


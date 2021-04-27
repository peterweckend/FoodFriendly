//
//  ReviewByUserModel.swift
//  Edible
//  This is used by the User page to fetch all Reviews for a given user
//  Accessed by user ID

import UIKit
import Firebase

class ReviewByUserModel {
    
    var key: String
    var description: String
    var isFoodGood: Bool?
    var isAtmosphereGood: Bool?
    var isEdibilityGood: Bool?
    var restaurantName: String
    var restaurantKey: String
    let ref: DatabaseReference?
    
    
    init?(description: String, isFoodGood: Bool?, isAtmosphereGood: Bool?, isEdibilityGood: Bool?, restaurantName: String, restaurantKey: String, key: String = "") {
        self.key = key
        self.description = description
        self.isFoodGood = isFoodGood
        self.isAtmosphereGood = isAtmosphereGood
        self.isEdibilityGood = isEdibilityGood
        self.restaurantName = restaurantName
        self.restaurantKey = restaurantKey
        self.ref = nil
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "description": description,
            "isFoodGood": isFoodGood as Any,
            "isAtmosphereGood": isAtmosphereGood as Any,
            "isEdibilityGood": isEdibilityGood as Any,
            "restaurantName": restaurantName as Any,
            "restaurantKey": restaurantKey as Any
            ] as NSDictionary
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        description = snapshotValue["description"] as! String
        isFoodGood = snapshotValue["isFoodGood"] as? Bool
        isAtmosphereGood = snapshotValue["isAtmosphereGood"] as? Bool
        isEdibilityGood = snapshotValue["isEdibilityGood"] as? Bool
        restaurantName = snapshotValue["restaurantName"] as! String
        restaurantKey = snapshotValue["restaurantKey"] as! String
        ref = snapshot.ref
        
    }
}


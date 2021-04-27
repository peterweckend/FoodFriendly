//
//  ReviewModel.swift
//  This is used by the Restaurant page to fetch all Reviews for a given restaurant
//  Accessed by restaurant ID

import UIKit
import Firebase

class ReviewModel {
    
    var key: String
    var description: String
    var reviewingUserId: String
    var isFoodGood: Bool?
    var isAtmosphereGood: Bool?
    var isEdibilityGood: Bool?
    let ref: DatabaseReference?
    
    
    init?(description: String, reviewingUserId: String, isFoodGood: Bool?, isAtmosphereGood: Bool?, isEdibilityGood: Bool?, key: String = "") {
        self.key = key
        self.description = description
        self.reviewingUserId = reviewingUserId
        self.isFoodGood = isFoodGood
        self.isAtmosphereGood = isAtmosphereGood
        self.isEdibilityGood = isEdibilityGood
        self.ref = nil
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "description": description,
            "reviewingUserId": reviewingUserId,
            "isFoodGood": isFoodGood as Any,
            "isAtmosphereGood": isAtmosphereGood as Any,
            "isEdibilityGood": isEdibilityGood as Any
            ] as NSDictionary
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        description = snapshotValue["description"] as! String
        reviewingUserId = snapshotValue["reviewingUserId"] as! String
        isFoodGood = snapshotValue["isFoodGood"] as? Bool
        isAtmosphereGood = snapshotValue["isAtmosphereGood"] as? Bool
        isEdibilityGood = snapshotValue["isEdibilityGood"] as? Bool
        ref = snapshot.ref
        
    }
}


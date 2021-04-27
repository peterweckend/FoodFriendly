//
//  RestaurantTagModel.swift
//  Edible
//
//  Created by Peter Weckend on 2018-04-21.
//  Copyright © 2018 Peter Weckend. All rights reserved.
//

import UIKit
import Firebase

class RestaurantTagModel {
    
    var key: String
    var ratingString: String
    var dishName: String
    var dishKey: String
    var reviewKey: String
    let ref: DatabaseReference?
    
    static var goodReview = "GOOD"
    static var badReview = "BAD"
    static var notEdibleReview = "NOTED"
    
    init?(ratingString: String, dishName: String, dishKey: String, reviewKey: String, key: String = "") {
        self.key = key
        self.ratingString = ratingString
        self.dishName = dishName
        self.dishKey = dishKey
        self.reviewKey = reviewKey
        self.ref = nil
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "ratingString": ratingString as Any,
            "dishName": dishName as Any,
            "dishKey": dishKey as Any,
            "reviewKey": reviewKey as Any
            ] as NSDictionary
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        ratingString = snapshotValue["ratingString"] as! String
        dishName = snapshotValue["dishName"] as! String
        dishKey = snapshotValue["dishKey"] as! String
        reviewKey = snapshotValue["reviewKey"] as! String
        ref = snapshot.ref
    }
}


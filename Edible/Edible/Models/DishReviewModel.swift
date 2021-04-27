//
//  DishReviewModel.swift
//  Edible

import UIKit
import Firebase

class DishReviewModel {
    
    var key: String
    var ratingString: String
    var dishName: String
    var dishKey: String
    var reviewKey: String
    let ref: DatabaseReference?
    
    static var goodReview = "GOOD"
    static var badReview = "BAD"
    static var notEdibleReview = "NOTEDIBLE"
    
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


//
//  DishRatingModel.swift
//  Edible

import Foundation
import Firebase

class DishRatingModel {
    
    var key: String
    var isGoodCount: Int
    var isBadCount: Int
    var isNotEdibleCount: Int
    let ref: DatabaseReference?
    
    
    init?(isGoodCount: Int, isBadCount: Int, isNotEdibleCount: Int, key: String = "") {
        self.key = key
        self.isGoodCount = isGoodCount
        self.isBadCount = isBadCount
        self.isNotEdibleCount = isNotEdibleCount
        self.ref = nil
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "isGoodCount": isGoodCount,
            "isBadCount": isBadCount,
            "isNotEdibleCount": isNotEdibleCount
            ] as NSDictionary
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        isGoodCount = snapshotValue["isGoodCount"] as! Int
        isBadCount = snapshotValue["isBadCount"] as! Int
        isNotEdibleCount = snapshotValue["isNotEdibleCount"] as! Int
        ref = snapshot.ref
        
    }
    
    // create an empty RatingModel
    init() {
        key = ""
        self.isGoodCount = 0
        self.isBadCount = 0
        self.isNotEdibleCount = 0
        self.ref = nil
    }
}


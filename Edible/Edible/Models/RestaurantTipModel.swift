//
//  RestaurantTipModel.swift
//  Edible

import UIKit
import Firebase

class RestaurantTipModel {
    
    var key: String
    var tipUserId: String
    var description: String
    let ref: DatabaseReference?
    var userName: String? = nil // transient value
    
    
    init?(tipUserId: String, description: String, key: String = "") {
        
        self.key = key
        self.tipUserId = tipUserId
        self.description = description
        self.ref = nil
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "description": description,
            "tipUserId": tipUserId,
            ] as NSDictionary
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        description = snapshotValue["description"] as! String
        tipUserId = snapshotValue["tipUserId"] as! String
        ref = snapshot.ref
        
    }
}


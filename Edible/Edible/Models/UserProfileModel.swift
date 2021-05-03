//
//  UserProfileModel.swift

import UIKit
import Firebase

class UserProfileModel {
    
    var key: String
    var firstName: String
    var lastName: String
    var photoUrl: String
    var dietName: String
    var isGlutenFree: Bool?
    let ref: DatabaseReference?
    
    init?(firstName: String, lastName: String, photoUrl: String = "", dietName: String, isGlutenFree: Bool?, key: String = "") {
        self.key = key
        self.firstName = firstName
        self.lastName = lastName
        self.photoUrl = photoUrl
        self.dietName = dietName
        self.isGlutenFree = isGlutenFree
        self.ref = nil
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "photoUrl": photoUrl,
            "dietName": dietName,
            "isGlutenFree": isGlutenFree as Any
            ] as NSDictionary
    }
    
    init(snapshot: DataSnapshot) {
        if !snapshot.exists() || snapshot.value is NSNull {
            print("User profile not found.")
        }
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        firstName = snapshotValue["firstName"] as! String
        lastName = snapshotValue["lastName"] as! String
        photoUrl = snapshotValue["photoUrl"] as! String
        dietName = snapshotValue["dietName"] as! String
        isGlutenFree = snapshotValue["isGlutenFree"] as? Bool
        ref = snapshot.ref
    }
}

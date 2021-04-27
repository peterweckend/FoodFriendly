//
//  RestaurantModel.swift

import UIKit
import Firebase
import Alamofire
import AlamofireImage

class RestaurantModel {
    
    var key: String
    var name: String
    var address1: String
    var address2: String
    var phoneNumber: String
    var photoUrl: String
    var hasGlutenFriendlyOptions: Bool
    var photo: UIImage?
    var isStarredByCurrentUser: Bool
    var lat: String
    var lng: String
    var tags: [String]
    var overallRating: Float? // transient attribute - will not be persisted
    var distanceFromUser: String? // transient attribute - will not be persisted
    var distanceFromUserInKm: Float? // transient attribute - will not be persisted
    let ref: DatabaseReference?
    
    
    init?(name: String, address1: String, address2: String, phoneNumber: String, hasGlutenFriendlyOptions: Bool = false, photoUrl: String = "", photo: UIImage?, lat: String, lng: String, key: String = "", tags: [String] = [], isStarredByCurrentUser: Bool = false) {
        if name.isEmpty {
            return nil
        }
        
        self.name = name
        self.address1 = address1
        self.address2 = address2
        self.phoneNumber = phoneNumber
        self.hasGlutenFriendlyOptions = hasGlutenFriendlyOptions
        self.photoUrl = photoUrl
        self.photo = photo
        self.key = key
        self.ref = nil
        self.lat = lat
        self.lng = lng
        self.tags = tags
        self.overallRating = nil
        self.distanceFromUser = nil
        self.distanceFromUserInKm = nil
        self.isStarredByCurrentUser = isStarredByCurrentUser
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "name": name,
            "address1": address1,
            "address2": address2,
            "phoneNumber": phoneNumber,
            "hasGlutenFriendlyOptions": hasGlutenFriendlyOptions,
            "photoUrl": photoUrl,
            "lat": lat,
            "lng": lng,
            "tags": tags
            ] as NSDictionary
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        address1 = snapshotValue["address1"] as! String
        address2 = snapshotValue["address2"] as! String
        phoneNumber = snapshotValue["phoneNumber"] as! String
        hasGlutenFriendlyOptions = snapshotValue["hasGlutenFriendlyOptions"] as! Bool
        photoUrl = snapshotValue["photoUrl"] as! String
        photo = UIImage(named: "Restaurant5")
        lat = NSString(format: "%@", snapshotValue["lat"] as! CVarArg) as String
        lng = NSString(format: "%@", snapshotValue["lng"] as! CVarArg) as String
        ref = snapshot.ref
        overallRating = nil
        distanceFromUser = nil
        distanceFromUserInKm = nil
        isStarredByCurrentUser = false
        //tags = snapshotValue[Constants.RestaurantTags] as! [String]
        tags = ["test tags 123"]
    }
    
    init(nsdictionary: NSDictionary) {
        name = nsdictionary["name"] as! String
        address1 = nsdictionary["address1"] as! String
        address2 = nsdictionary["address2"] as! String
        phoneNumber = nsdictionary["phoneNumber"] as! String
        hasGlutenFriendlyOptions = nsdictionary["hasGlutenFriendlyOptions"] as! Bool
        photoUrl = nsdictionary["photoUrl"] as! String
        lat = NSString(format: "%@", nsdictionary["lat"] as! CVarArg) as String
        lng = NSString(format: "%@", nsdictionary["lng"] as! CVarArg) as String
        //tags = nsdictionary[Constants.RestaurantTags] as! [String]
        tags = ["test tags 123"]
        isStarredByCurrentUser = false
        key = ""
        ref = nil
        overallRating = nil
        distanceFromUser = nil
        distanceFromUserInKm = nil
    }
}





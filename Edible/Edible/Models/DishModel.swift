//
//  DishModel.swift

import UIKit
import Firebase
import Alamofire
import AlamofireImage


class DishModel {
    
    static let mainIdentifier = "M"
    static let sidesIdentifier = "S"
    static let appetizerIdentifier = "A"
    
    static let isVegan = "VEGAN"
    static let isVegetarian = "VEGETARIAN"
    static let canBeMadeVegan = "CBMVEGAN"
    static let canBeMadeVegetarian = "CBMVEGETARIAN"
    static let noneOfTheAbove = "NONE"
    
    var key: String
    var name: String
    var category: String
    var description: String
    var isVegan: Bool
    var canBeMadeVegan: Bool
    var isVegetarian: Bool
    var canBeMadeVegetarian: Bool
    var overallRating: Float? // transient attribute - will not be persisted
    
    let ref: DatabaseReference?
    
    
    init?(name: String, category: String, description: String, isVegan: Bool = false, canBeMadeVegan: Bool = false, isVegetarian: Bool = false, canBeMadeVegetarian: Bool = false, key: String = "") {
        if name.isEmpty {
            return nil
        }
        
        self.key = key
        self.name = name
        self.category = category.uppercased()
        self.description = description
        self.isVegan = isVegan
        self.canBeMadeVegan = canBeMadeVegan
        self.isVegetarian = isVegetarian
        self.canBeMadeVegetarian = canBeMadeVegetarian
        self.ref = nil
        self.overallRating = nil
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "name": name,
            "category": category.uppercased(),
            "description": description,
            "vegan": isVegan,
            "canBeMadeVegan": canBeMadeVegan,
            "vegetarian": isVegetarian,
            "canBeMadeVegetarian": canBeMadeVegetarian,
            ] as NSDictionary
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        category = (snapshotValue["category"] as! String).uppercased()
        description = snapshotValue["description"] as! String
        isVegan = snapshotValue["vegan"] as! Bool
        canBeMadeVegan = snapshotValue["canBeMadeVegan"] as! Bool
        isVegetarian = snapshotValue["vegetarian"] as! Bool
        canBeMadeVegetarian = snapshotValue["canBeMadeVegetarian"] as! Bool
        overallRating = nil
        ref = snapshot.ref
        
    }
}


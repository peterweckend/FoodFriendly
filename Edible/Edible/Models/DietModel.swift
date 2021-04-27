//
//  DietModel.swift

import UIKit

class DietModel {
    
    static let vegan = "vegan"
    static let vegetarian = "vegetarian"
    
    var name: String
    
    init?(name: String) {
        self.name = name
    }
}

//
//  DietHelper.swift
//  Edible

import Foundation
import Firebase

class DietHelper {
    static let dietFriendly = "D"
    static let canBeMadeFriendly = "CBM"
    static let notFriendly = "N"
    
    // returns a string specifying what diet icon should be displayed for an object
    static func isDietAppropriate(dish: DishModel, diet: DietModel) -> String {
        if diet.name == DietModel.vegan {
            if dish.isVegan {
                return self.dietFriendly
            } else if dish.canBeMadeVegan {
                return self.canBeMadeFriendly
            } else {
                return self.notFriendly
            }
        } else { // it's vegetarian
            if dish.isVegan || dish.isVegetarian {
                return self.dietFriendly
            } else if dish.canBeMadeVegan || dish.canBeMadeVegetarian {
                return self.canBeMadeFriendly
            } else {
                return self.notFriendly
            }
        }
    }
}

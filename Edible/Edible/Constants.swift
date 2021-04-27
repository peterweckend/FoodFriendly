//
//  Constants.swift
//  Edible

import Foundation

struct Constants {
    
    // Firebase Constants
    static let RestaurantRatings = "restaurantRatings"
    static let Restaurants = "restaurants"
    static let StarredRestaurants = "starredRestaurants"
    static let RestaurantTips = "restaurantTips"
    static let RestaurantTags = "restaurantTags"
    static let DishRatings = "dishRatings"
    static let Reviews = "reviews"
    static let ReviewsByUser = "reviewsByUser"
    
    // URLs
    static let edibleURL = "http://www.google.ca/"
    static let feedbackFormURL = "http://www.google.ca/"
    
    static let optionsStrings = [["My Profile", "Reset Password"], ["Disclaimer", "Feedback",  "About"], ["Log Out"]]
    static let optionsSegueIdentifiers = [["viewProfile", "resetPassword"], ["viewDisclaimer", "feedback",  "about"], ["unwindToIntroWithSegue"]]

    static let sectionIdentifiers = ["Account", "Support", "Options"]
    
    static let tipText = "Help your fellow FoodFriendly users order at "
}

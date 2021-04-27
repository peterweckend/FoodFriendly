//
//  RestaurantHelper.swift
//  Edible

import Foundation
import Firebase

class RestaurantHelper {
    
    // given a ReviewModel, this will update or create a RatingModel for a restaurant
    static func addRatingToRestaurant(reviewModel: ReviewModel, restaurantKey: String) {
        let restaurantRatingsRef = Database.database().reference(withPath: Constants.RestaurantRatings)
        
        restaurantRatingsRef.child("\(restaurantKey)").observeSingleEvent(of: .value, with: { (snapshot) in
            var rating = RatingModel()
            
            if(snapshot.exists()) {
                // if the restaurant already has reviews
                rating = RatingModel(snapshot: snapshot)
            }
            
            if reviewModel.isAtmosphereGood != nil {
                rating.isAtmosphereGoodTotalCount += 1
                if reviewModel.isAtmosphereGood! {
                    rating.isAtmosphereGoodPosCount += 1
                }
            }
            
            if reviewModel.isFoodGood != nil {
                rating.isFoodGoodTotalCount += 1
                if reviewModel.isFoodGood! {
                    rating.isFoodGoodPosCount += 1
                }
            }
            
            if reviewModel.isEdibilityGood != nil {
                rating.isEdibilityGoodTotalCount += 1
                if reviewModel.isEdibilityGood! {
                    rating.isEdibilityGoodPosCount += 1
                }
            }
            
            // upload the rating for the restaurant
            restaurantRatingsRef.child("\(restaurantKey)").setValue(rating.toAnyObject())
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    // given a ReviewModel, this will update or create a RatingModel for a restaurant
    static func addRatingToDish(dishReviewModel: DishReviewModel, restaurantKey: String, dishKey: String) {
        
        let dishRatingsRef = Database.database().reference(withPath: Constants.DishRatings)
        
        dishRatingsRef.child("\(restaurantKey)/\(dishKey)").observeSingleEvent(of: .value, with: { (snapshot) in
            var rating = DishRatingModel()
            
            if(snapshot.exists()) {
                // if the dish already has reviews
                rating = DishRatingModel(snapshot: snapshot)
            }
            
            if dishReviewModel.ratingString == DishReviewModel.goodReview {
                rating.isGoodCount += 1
            } else if dishReviewModel.ratingString == DishReviewModel.badReview {
                rating.isBadCount += 1
            } else if dishReviewModel.ratingString == DishReviewModel.notEdibleReview {
                rating.isNotEdibleCount += 1
            } else { // if the dish review somehow has no rating
                return
            }
            
            // upload the rating for the restaurant
            dishRatingsRef.child("\(restaurantKey)/\(dishKey)").setValue(rating.toAnyObject())
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    // given a RatingModel, this will find the overall rating for a restaurant
    static func findOverallRestaurantRating(ratingModel: RatingModel) -> Float {
        let foodRating = Float(ratingModel.isFoodGoodPosCount) / Float(ratingModel.isFoodGoodTotalCount)
        let atmosphereRating = Float(ratingModel.isAtmosphereGoodPosCount) / Float(ratingModel.isAtmosphereGoodTotalCount)
        let edibleRating = Float(ratingModel.isEdibilityGoodPosCount) / Float(ratingModel.isEdibilityGoodTotalCount)
        return (foodRating + atmosphereRating + edibleRating) / 3
    }
    
    // given a DishRatingModel, this will find the overall rating for a dish
    // if there are no good or bad reviews, this will return nil
    static func findOverallDishRating(ratingModel: DishRatingModel) -> Float? {
        if ratingModel.isGoodCount == 0 && ratingModel.isBadCount == 0 {
            return nil
        }
        let dishRating = Float(ratingModel.isGoodCount) / (Float(ratingModel.isGoodCount) + Float(ratingModel.isBadCount))
        return dishRating
    }
    
    // given a floating point rating, convert to user friendly percentage
    // ex: 0.705 is converted to 71%
    static func convertRatingToStringPercentage(rating: Float) -> String {
        return String(Int((rating * 100).rounded())) + "%"
    }
    
}

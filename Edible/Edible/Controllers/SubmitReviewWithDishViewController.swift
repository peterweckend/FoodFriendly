//
//  SubmitReviewWithDishViewController.swift
//  Edible

import UIKit
import Firebase

class SubmitReviewWithDishViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var dishNameLabel: UILabel!
    var restaurantId: String?
    var restaurantName: String?
    var selectedDish: DishModel?
    var dishRatingDisplayStrings = ["Great", "Bad", "Not Edible"]
    var dishCodedRatings = [DishReviewModel.goodReview, DishReviewModel.badReview, DishReviewModel.notEdibleReview]
    
    var dishRating: String? = nil
    @IBOutlet weak var ratingTableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    let generator = UIImpactFeedbackGenerator(style: .light)
    var review: ReviewModel?
    var reviewByUser: ReviewByUserModel?
    var reviewImage: UIImage?
    let reviewsRef = Database.database().reference(withPath: "reviews")
    let reviewsByUserRef = Database.database().reference(withPath: "reviewsByUser")
    let dishReviewsRef = Database.database().reference(withPath: "dishReviews")
    let user = Auth.auth().currentUser
    
    var ratingSelected = false {
        didSet{
            if ratingSelected {
                // enabled the submit button
                submitButton.isEnabled = true
                submitButton.backgroundColor = UIColor.orange
            } else {
                dishRating = nil
                // disable the submit button
                submitButton.isEnabled = false
                submitButton.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dishNameLabel.text = selectedDish?.name
        submitButton.backgroundColor = UIColor.lightGray
        dishRating = nil
        ratingSelected = false
        
        ratingTableView.dataSource = self
        ratingTableView.delegate = self
        ratingTableView.alwaysBounceVertical = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dishCodedRatings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ratingCell", for: indexPath) as? MenuReviewTableViewCell else {
            fatalError("The dequeued cell is not an instance of MenuReviewTableViewCell")
        }
        cell.ratingLabel.text = dishRatingDisplayStrings[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ratingSelected = true
        dishRating = dishCodedRatings[indexPath.row]
        generator.impactOccurred()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reviewCompletedFromDishSegue" {
            guard let reviewConfirmationViewController = segue.destination as? ReviewConfirmationViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            reviewConfirmationViewController.numberOfViewsToMoveBy = 5
        }
    }
    
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if dishRating == nil {
            return
        }
        if let user = self.user {
            let userId = user.uid
            // add the review to the restaurant review list
            let restaurantReviewRef = reviewsRef.child("\(restaurantId!)").childByAutoId()
            restaurantReviewRef.setValue(review?.toAnyObject())
            
            // add the review to the user's review list
            let userReviewRef = reviewsByUserRef.child("\(userId)").childByAutoId()
            userReviewRef.setValue(reviewByUser?.toAnyObject())
            
            let dishReviewRef = dishReviewsRef.child("\(restaurantId!)/\(restaurantReviewRef.key)")
            let dishReview = DishReviewModel(ratingString: dishRating!, dishName: selectedDish!.name, dishKey: selectedDish!.key, reviewKey: restaurantReviewRef.key)
            dishReviewRef.setValue(dishReview?.toAnyObject())
            
            RestaurantHelper.addRatingToRestaurant(reviewModel: review!, restaurantKey: restaurantId!)
            RestaurantHelper.addRatingToDish(dishReviewModel: dishReview!, restaurantKey: restaurantId!, dishKey: selectedDish!.key)
        }
        self.performSegue(withIdentifier: "reviewCompletedFromDishSegue", sender: self)
    }
    
    func returnToViewRestaurant() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 4], animated: true)
    }
    

}

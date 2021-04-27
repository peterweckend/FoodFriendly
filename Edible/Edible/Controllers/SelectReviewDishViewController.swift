//
//  SelectReviewDishViewController.swift
//  Edible

import UIKit
import Firebase

class SelectReviewDishViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var menuSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var dishesTableView: UITableView!
    var dishes = [DishModel]()
    var filteredDishes = [DishModel]()
    var currentlySelectedItem: String = DishModel.appetizerIdentifier
    var restaurantId: String?
    var restaurantName: String?
    var selectedDish: DishModel? = nil
    var review: ReviewModel?
    var reviewByUser: ReviewByUserModel?
    var reviewImage: UIImage?
    let user = Auth.auth().currentUser
    
    let reviewsRef = Database.database().reference(withPath: "reviews")
    let reviewsByUserRef = Database.database().reference(withPath: "reviewsByUser")
    let restaurantRatingsRef = Database.database().reference(withPath: Constants.RestaurantRatings)
    
    var dishSelected = false {
        didSet{
            if dishSelected {
                // enabled the Next button
                nextButton.isEnabled = true
                nextButton.backgroundColor = UIColor.orange
            } else {
                selectedDish = nil
                // disable the Next button
                nextButton.isEnabled = false
                nextButton.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuSegmentedControl.selectedSegmentIndex = 0
        nextButton.isEnabled = false
        nextButton.backgroundColor = UIColor.lightGray
        currentlySelectedItem = DishModel.appetizerIdentifier
        
        dishesTableView.dataSource = self
        dishesTableView.delegate = self
        
        // only want dishes for the loaded restaurant
        let dishesRef = Database.database().reference(withPath: "dishes/\(restaurantId!)")
        
        // Listen for new dishes in the Firebase database
        // should be something like ref.queryby... .observe
        dishesRef.observe(.childAdded, with: { (snapshot) -> Void in
            print("dish found")
            let dish = DishModel(snapshot: snapshot)
            self.dishes.append(dish)
            self.loadDishTable(dishType: self.currentlySelectedItem)
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rateSelectedDish" {
            guard let submitReviewWithDishViewController = segue.destination as? SubmitReviewWithDishViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            submitReviewWithDishViewController.restaurantId = restaurantId
            submitReviewWithDishViewController.restaurantName = restaurantName
            submitReviewWithDishViewController.selectedDish = selectedDish
            submitReviewWithDishViewController.review = review
            submitReviewWithDishViewController.reviewByUser = reviewByUser
            if reviewImage != nil {
                submitReviewWithDishViewController.reviewImage = reviewImage!
            }
        } else if segue.identifier == "reviewCompletedSegue" {
            if let user = self.user {
                let userId = user.uid
                //submit review
                let restaurantReviewRef = reviewsRef.child("\(restaurantId!)").childByAutoId()
                restaurantReviewRef.setValue(review?.toAnyObject())
                
                // add the review to the user's review list
                let userReviewRef = reviewsByUserRef.child("\(userId)").childByAutoId()
                userReviewRef.setValue(reviewByUser?.toAnyObject())
                
                // add the review's ratings to the restaurant's ratings
                RestaurantHelper.addRatingToRestaurant(reviewModel: review!, restaurantKey: restaurantId!)
            }
            
            guard let reviewConfirmationViewController = segue.destination as? ReviewConfirmationViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            reviewConfirmationViewController.numberOfViewsToMoveBy = 4
            
        }
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if selectedDish != nil {
            self.performSegue(withIdentifier: "rateSelectedDish", sender: self)
        }
    }
    
    // MARK: - TableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDishes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dishCell", for: indexPath) as? ReviewDishTableViewCell else {
            fatalError("The dequeued cell is not an instance of ReviewDishTableViewCell")
        }
        let dishItem = filteredDishes[indexPath.row]
        cell.dishTitleLabel.text = dishItem.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dishSelected = true
        selectedDish = filteredDishes[indexPath.row]
    }
    
    // MARK: - Filter methods
    func loadDishTable(dishType: String) {
        filteredDishes = []
        for dish in dishes {
            if dish.category == dishType {
                self.filteredDishes.append(dish)
            }
        }
        self.dishesTableView.reloadData()
    }
    
    @IBAction func segmentedControlChange(_ sender: UISegmentedControl) {
        dishSelected = false
        switch sender.selectedSegmentIndex {
        case 0:
            loadDishTable(dishType: DishModel.appetizerIdentifier)
        case 1:
            loadDishTable(dishType: DishModel.mainIdentifier)
        case 2:
            loadDishTable(dishType: DishModel.sidesIdentifier)
        default:
            break
            
        }
    }
    
    
}

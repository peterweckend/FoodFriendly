//
//  UserProfileViewController.swift

import UIKit
import Firebase

class UserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var userReviewCount: UILabel!
    @IBOutlet weak var dietImageView: UIImageView!
    var authUser = Auth.auth().currentUser
    var reviews = [ReviewByUserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reviewTableView.dataSource = self
        reviewTableView.delegate = self
        
        if let authUser = authUser {
            // download user information
            let userProfileRef = Database.database().reference(withPath: "userProfiles/\(authUser.uid)")
            userProfileRef.observe(DataEventType.value, with: { (snapshot) in
                let userProfile = UserProfileModel(snapshot: snapshot)
                self.userNameLabel.text = userProfile.firstName + " " + userProfile.lastName
                self.userProfileImageView.af_setImage(withURL: Foundation.URL(string: userProfile.photoUrl)!)
                
                if userProfile.dietName == DietModel.vegan {
                    self.dietImageView.image = UIImage(named: "vegan")
                } else if userProfile.dietName == DietModel.vegetarian {
                    self.dietImageView.image = UIImage(named: "veg")
                }
            })
            
            let reviewsByUserRef = Database.database().reference(withPath: "reviewsByUser/\(authUser.uid)")
            reviewsByUserRef.observe(.childAdded, with: { (snapshot) -> Void in
                let reviewByUser = ReviewByUserModel(snapshot: snapshot)
                self.reviews.append(reviewByUser)
                self.reviewTableView.reloadData()
                self.userReviewCount.text = String(self.reviews.count)
            })
            
        } else {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileReviewCell", for: indexPath) as? UserProfileReviewTableViewCell else {
            fatalError("The dequeued cell is not an instance of UserProfileReviewCell")
        }
        let review = reviews[indexPath.row]
        cell.restaurantNameLabel.text = review.restaurantName
        cell.reviewDescription.text = review.description
        
        if review.isFoodGood == nil {
            cell.foodRatingLabel.text = ""
            cell.foodRatingImageView.image = nil
        } else if review.isFoodGood == true {
            cell.foodRatingImageView.image = UIImage(named: "starrestaurantview")
        } else {
            cell.foodRatingImageView.image = UIImage(named: "starbuttonunselected")
        }
        
        if review.isAtmosphereGood == nil {
            cell.atmosphereRatingLabel.text = ""
            cell.atmosphereRatingImageView.image = nil
        } else if review.isAtmosphereGood == true {
            cell.atmosphereRatingImageView.image = UIImage(named: "starrestaurantview")
        } else {
            cell.atmosphereRatingImageView.image = UIImage(named: "starbuttonunselected")
        }
        
        if review.isEdibilityGood == nil {
            cell.edibleRatingLabel.text = ""
            cell.edibleRatingImageView.image = nil
        } else if review.isEdibilityGood == true {
            cell.edibleRatingImageView.image = UIImage(named: "starrestaurantview")
        } else {
            cell.edibleRatingImageView.image = UIImage(named: "starbuttonunselected")
        }
        
        return cell
    }

}

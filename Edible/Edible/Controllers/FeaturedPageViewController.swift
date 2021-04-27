//
//  FeaturedPageViewController.swift

import UIKit
import Firebase
import Alamofire
import AlamofireImage

class FeaturedPageViewController: UITableViewController, RestaurantTableViewCellDelegate {

    @IBOutlet var restaurantTableView: UITableView!
    var restaurants = [RestaurantModel]()
    var starredDict = [String : Int]()
    
    let restaurantRef = Database.database().reference(withPath: Constants.Restaurants)
    let starredRef = Database.database().reference(withPath: Constants.StarredRestaurants)
    let restaurantRatingsRef = Database.database().reference(withPath: Constants.RestaurantRatings)
    let restaurantTagsRef = Database.database().reference(withPath: Constants.RestaurantTags)
    
    let user = Auth.auth().currentUser

    override func viewDidLoad() {
        super.viewDidLoad()

        // Listen for new restaurants in the Firebase database
        restaurantRef.observe(.childAdded, with: { (snapshot) -> Void in
            let restaurant = RestaurantModel(snapshot: snapshot)
            
            // get restaurant rating if it exists
            self.restaurantRatingsRef.child("\(restaurant.key)").observe(.value, with: { (snapshot) in
                if(snapshot.exists()) {
                    restaurant.overallRating = RestaurantHelper.findOverallRestaurantRating(ratingModel: RatingModel(snapshot: snapshot))
                    self.tableView.reloadData()
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
            if !restaurant.photoUrl.isEmpty {
                Alamofire.request(restaurant.photoUrl).responseImage { response in
                    if let restaurantImage = response.result.value {
                        restaurant.photo = restaurantImage
                    }
                    
                    self.restaurants.append(restaurant)
                    self.tableView.reloadData()
                    self.updateStarredRestaurants()
                }
            } else {
                self.restaurants.append(restaurant)
                self.tableView.reloadData()
                self.updateStarredRestaurants()
            }
        })

        // keep track of which restaurants are starred
        if let user = self.user {
            let userStarredRestaurantRef = Database.database().reference(withPath: "\(Constants.StarredRestaurants)/\(user.uid)")
            userStarredRestaurantRef.observe(DataEventType.value, with: { (snapshot) in
                self.starredDict = snapshot.value as? [String : Int] ?? [:]
                for restaurant in self.restaurants {
                    if self.starredDict[restaurant.key] == 1 {
                        restaurant.isStarredByCurrentUser = true
                    } else {
                        restaurant.isStarredByCurrentUser = false
                    }
                }
                self.tableView.reloadData()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RestaurantTableViewCell"

        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RestaurantTableViewCell  else {
            fatalError("The dequeued cell is not an instance of RestaurantTableViewCell.")
        }
        cell.delegate = self
        
        // Fetches the appropriate meal for the data source layout.
        let restaurant = restaurants[indexPath.row]
        
        cell.nameLabel.text = restaurant.name
        cell.addressLabel.text = restaurant.address1
        cell.restaurantImageView.image = restaurant.photo
        
        var tags = ""
        for tag in restaurant.tags {
            if tags == "" {
                tags = tag.capitalized
            } else {
                tags = tags + ", " + tag.capitalized
            }
        }
        cell.tagLabel.text = tags
        
        if restaurant.overallRating == nil {
            cell.restaurantProgressView.isHidden = true
            cell.reviewPercentLabel.isHidden = true
            cell.reviewStaticLabel.isHidden = true
        } else {
            cell.restaurantProgressView.isHidden = false
            cell.reviewPercentLabel.isHidden = false
            cell.reviewStaticLabel.isHidden = false
            cell.restaurantProgressView.progress = restaurant.overallRating!
            cell.reviewPercentLabel.text = RestaurantHelper.convertRatingToStringPercentage(rating: restaurant.overallRating!)
        }
        
        if restaurant.isStarredByCurrentUser {
            cell.starButton.setImage(UIImage(named: "starselected"), for: UIControlState.normal)
        } else {
            cell.starButton.setImage(UIImage(named: "starunselected"), for: UIControlState.normal)
        }
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "openSettingsFromHomeScreen" {
            // perform any custom actions here
        } else {
            guard let restaurantViewController = segue.destination as? RestaurantViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedRestaurantCell = sender as? RestaurantTableViewCell else {
                fatalError("Unexpected sender")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedRestaurantCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedRestaurant = restaurants[indexPath.row]
            restaurantViewController.restaurant = selectedRestaurant
        }
    }
    
    
    func buttonTapped(cell: RestaurantTableViewCell) {
        guard let indexPath = restaurantTableView.indexPath(for: cell) else {
            return
        }
        let restaurant = restaurants[indexPath.row]
        if let user = user {
            let uid = user.uid
            if starredDict[restaurant.key] == 1 {
                starredRef.child("\(uid)/\(restaurant.key)").setValue(0)
                // just in case
                starredDict[restaurant.key] = 0
            } else {
                starredRef.child("\(uid)/\(restaurant.key)").setValue(1)
                starredDict[restaurant.key] = 1
            }
        }
    }
    
    func updateStarredRestaurants() {
        for restaurant in restaurants {
            if starredDict[restaurant.key] == 1 {
                restaurant.isStarredByCurrentUser = true
            } else {
                restaurant.isStarredByCurrentUser = false
            }
        }
        self.tableView.reloadData()
    }

}











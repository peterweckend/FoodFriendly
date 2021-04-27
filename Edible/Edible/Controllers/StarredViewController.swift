//
//  StarredViewController.swift

import UIKit
import Firebase
import Alamofire
import AlamofireImage

class StarredViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, StarredRestaurantTableViewCellDelegate {
    
    var starredRestaurants = [RestaurantModel]()
    var starredDict = [String : Int]()
    
    let user = Auth.auth().currentUser
    let restaurantRef = Database.database().reference(withPath: "restaurants")
    let restaurantRatingsRef = Database.database().reference(withPath: Constants.RestaurantRatings)
    
    @IBOutlet weak var starredRestaurantTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return starredRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StarredRestaurantTableViewCell", for: indexPath) as? StarredRestaurantTableViewCell else {
            fatalError("The dequeued cell is not an instance of StarredRestaurantTableViewCell")
        }
        cell.delegate = self
        let starredRestaurant = starredRestaurants[indexPath.row]
        cell.nameLabel.text = starredRestaurant.name
        cell.addressLabel.text = starredRestaurant.address1
        cell.restaurantImageView.image = starredRestaurant.photo
        
        var tags = ""
        for tag in starredRestaurant.tags {
            if tags == "" {
                tags = tag.capitalized
            } else {
                tags = tags + ", " + tag.capitalized
            }
        }
        cell.tagsLabel.text = tags
        
        if starredRestaurant.overallRating == nil {
            cell.ratingProgressView.isHidden = true
            cell.ratingPercentage.isHidden = true
            cell.ratingStaticLabel.isHidden = true
        } else {
            cell.ratingProgressView.isHidden = false
            cell.ratingPercentage.isHidden = false
            cell.ratingStaticLabel.isHidden = false
            cell.ratingProgressView.progress = starredRestaurant.overallRating!
            cell.ratingPercentage.text = RestaurantHelper.convertRatingToStringPercentage(rating: starredRestaurant.overallRating!)
        }
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        starredRestaurantTableView.dataSource = self
        starredRestaurantTableView.delegate = self
        
        // get list of starred restaurants
        if let user = self.user {
            let userStarredRestaurantRef = Database.database().reference(withPath: "starredRestaurants/\(user.uid)")
            userStarredRestaurantRef.observe(DataEventType.value, with: { (snapshot) in
                self.starredDict = snapshot.value as? [String : Int] ?? [:]
                for (restaurantID, isStarred) in self.starredDict {
                    if isStarred == 1 {
                        // check if the restaurant is newly starred or not currently loaded on the screen
                        var isNewlyStarred = true
                        for existingRestaurant in self.starredRestaurants {
                            if existingRestaurant.key == restaurantID {
                                isNewlyStarred = false
                            }
                        }
                        if isNewlyStarred {
                            // add newly starred restaurant to page
                            self.restaurantRef.child("\(restaurantID)").observeSingleEvent(of: .value, with: { (snapshot) in
                                let restaurant = RestaurantModel(snapshot: snapshot)
                                
                                // get restaurant rating if it exists
                                self.restaurantRatingsRef.child("\(restaurant.key)").observe(.value, with: { (snapshot) in
                                    if(snapshot.exists()) {
                                        restaurant.overallRating = RestaurantHelper.findOverallRestaurantRating(ratingModel: RatingModel(snapshot: snapshot))
                                    }
                                }) { (error) in
                                    print(error.localizedDescription)
                                }
                                
                                if !restaurant.photoUrl.isEmpty {
                                    Alamofire.request(restaurant.photoUrl).responseImage { response in
                                        if let restaurantImage = response.result.value {
                                            restaurant.photo = restaurantImage
                                        }
                                        self.starredRestaurants.append(restaurant)
                                        self.starredRestaurantTableView.reloadData()
                                    }
                                } else {
                                    self.starredRestaurants.append(restaurant)
                                    self.starredRestaurantTableView.reloadData()
                                }
                                
                            }) { (error) in
                                print(error.localizedDescription)
                            }
                        }
                    } else {
                        // if there is an unstarred restaurant in the user's list, remove from the screen
                        for (index, restaurant) in self.starredRestaurants.enumerated() {
                            if restaurant.key == restaurantID {
                                self.starredRestaurants.remove(at: index)
                                self.starredRestaurantTableView.reloadData()
                                print(self.starredRestaurants.count)
                                break
                            }
                        }
                    }
                }
                self.starredRestaurantTableView.reloadData()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "openSettingsSegue" {
            // perform any custom actions here
        } else {
            guard let restaurantViewController = segue.destination as? RestaurantViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedRestaurantCell = sender as? StarredRestaurantTableViewCell else {
                fatalError("Unexpected sender")
            }

            guard let indexPath = starredRestaurantTableView.indexPath(for: selectedRestaurantCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let selectedRestaurant = starredRestaurants[indexPath.row]
            restaurantViewController.restaurant = selectedRestaurant
            starredRestaurantTableView.deselectRow(at: indexPath, animated: true)
        }
    }
 
    
    // fetches the restaurant object from database by provided ID
    // not used
    func fetchRestaurant(restaurantID: String) {
        restaurantRef.child("\(restaurantID)").observeSingleEvent(of: .value, with: { (snapshot) in
            let restaurant = RestaurantModel(snapshot: snapshot)
            self.starredRestaurants.append(restaurant)
            self.starredRestaurantTableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // star button tapped
    func buttonTapped(cell: StarredRestaurantTableViewCell) {
        guard let indexPath = starredRestaurantTableView.indexPath(for: cell) else {
            return
        }
        let starredRef = Database.database().reference(withPath: Constants.StarredRestaurants)
        let restaurant = starredRestaurants[indexPath.row]
        if let user = user {
            let uid = user.uid
            // you are only ever removing starred restaurants from this page
            starredRestaurants.remove(at: indexPath.row)
            starredRef.child("\(uid)/\(restaurant.key)").setValue(0)
            starredRestaurantTableView.reloadData()
        }
    }

}

//
//  RestaurantMenuViewController.swift
//  Edible

import UIKit
import Firebase

class RestaurantMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    static let vegetarianSectionHeaders = ["Vegetarian Dishes", "Can Be Made Vegetarian Dishes"]
    static let veganSectionHeaders = ["Vegan Dishes", "Can Be Made Vegan Dishes"]
    
    @IBOutlet weak var menuSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dishesTableView: UITableView!
    
    var dishes = [DishModel]()
    var filteredDishes = [DishModel]()
    var filteredDietDishes = [DishModel]()
    var filteredCanBeMadeDishes = [DishModel]()
    var sectionDishes: [[DishModel]] = []
    var restaurantId: String?
    var restaurantName: String?
    var currentlySelectedItem: String = DishModel.appetizerIdentifier
    let dishRatingRef = Database.database().reference(withPath: Constants.DishRatings)
    var authUser = Auth.auth().currentUser
    var userDiet: String? = nil // vegan by default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuSegmentedControl.selectedSegmentIndex = 0
        currentlySelectedItem = DishModel.appetizerIdentifier
        dishesTableView.dataSource = self
        dishesTableView.delegate = self
        
        if let authUser = authUser {
            let userProfileRef = Database.database().reference(withPath: "userProfiles/\(authUser.uid)")
            userProfileRef.observe(DataEventType.value, with: { (snapshot) in
                let userProfile = UserProfileModel(snapshot: snapshot)
                if userProfile.dietName == DietModel.vegan {
                    self.userDiet = DietModel.vegan
                } else if userProfile.dietName == DietModel.vegetarian {
                    self.userDiet = DietModel.vegetarian
                }
                self.loadDishTable(dishType: self.currentlySelectedItem)
            })
        }
        
        // only want dishes for the loaded restaurant
        let dishesRef = Database.database().reference(withPath: "dishes/\(restaurantId!)")
        
        // Listen for new dishes in the Firebase database
        dishesRef.observe(.childAdded, with: { (snapshot) -> Void in
            let dish = DishModel(snapshot: snapshot)
            
            // get dish rating if it exists
            self.dishRatingRef.child("\(self.restaurantId!)/\(dish.key)").observe(.value, with: { (snapshot) in
                if(snapshot.exists()) {
                    dish.overallRating = RestaurantHelper.findOverallDishRating(ratingModel: DishRatingModel(snapshot: snapshot))
                    self.dishesTableView.reloadData()
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
            self.dishes.append(dish)
            self.loadDishTable(dishType: self.currentlySelectedItem)
        })
        
        
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
    
    // MARK: - TableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionDishes[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if userDiet == nil {
            return 0
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filteredDietDishes.count == 0 && section == 0 {
            return nil
        }
        if filteredCanBeMadeDishes.count == 0 && section == 1 {
            return nil
        }
        if userDiet == DietModel.vegan {
            return RestaurantMenuViewController.veganSectionHeaders[section]
        } else if userDiet == DietModel.vegetarian {
            
            return RestaurantMenuViewController.vegetarianSectionHeaders[section]
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as? RestaurantMenuTableViewCell else {
            fatalError("The dequeued cell is not an instance of RestaurantMenuTableViewCell")
        }
        let dishItem = sectionDishes[indexPath.section][indexPath.row]
        cell.dishTitleLabel.text = dishItem.name
        cell.dishDescriptionLabel.text = dishItem.description
        if dishItem.overallRating == nil {
            cell.dishRatingProgressView.isHidden = true
            cell.dishRatingLabel.isHidden = true
            cell.dishRatingStaticLabel.isHidden = true
        } else {
            cell.dishRatingProgressView.progress = dishItem.overallRating!
            cell.dishRatingLabel.text = RestaurantHelper.convertRatingToStringPercentage(rating: dishItem.overallRating!)
            cell.dishRatingProgressView.isHidden = false
            cell.dishRatingLabel.isHidden = false
            cell.dishRatingStaticLabel.isHidden = false
        }
        
        return cell
    }
    
    // MARK: - Filter methods
    func loadDishTable(dishType: String) {
        filteredDietDishes = []
        filteredCanBeMadeDishes = []
        if userDiet != nil {
            for dish in dishes {
                if dish.category == dishType && userDiet != nil {
                    let dietCategory = DietHelper.isDietAppropriate(dish: dish, diet: DietModel(name: userDiet!)!)
                    if  dietCategory == DietHelper.dietFriendly {
                        // add to diet friendly list
                        self.filteredDietDishes.append(dish)
                    } else if dietCategory == DietHelper.canBeMadeFriendly {
                        // add to can be made friendly list
                        self.filteredCanBeMadeDishes.append(dish)
                    }
                }
            }
        }
        sectionDishes = [filteredDietDishes, filteredCanBeMadeDishes]
        self.dishesTableView.reloadData()
    }
    
    @IBAction func segmentedControlChange(_ sender: UISegmentedControl) {
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

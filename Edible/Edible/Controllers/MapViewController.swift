//
//  MapViewController.swift

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import Alamofire
import AlamofireImage
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, StarredMapTableViewCellDelegate, receivesFilterModelData {
    
    @IBOutlet weak var restaurantSearchBar: UISearchBar!
    @IBOutlet weak var restaurantTableView: UITableView!
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    let restaurantRef = Database.database().reference(withPath: Constants.Restaurants)
    let restaurantRatingsRef = Database.database().reference(withPath: Constants.RestaurantRatings)
    var restaurants = [String:RestaurantModel]()
    var restaurantsList = [RestaurantModel]()
    var filteredRestaurantsList = [RestaurantModel]()
    var tappedIconRestaurant: RestaurantModel?
    var starredDict = [String : Int]()
    var userCurrentLocation: CLLocation? = nil
    var user = Auth.auth().currentUser
    @IBOutlet weak var filterButton: UIBarButtonItem!
    var timer = Timer() // todo: find more elegant solution
    var elapsedTime = 0
    var maxElapsedTime = 20
    var isLocationEnabled = false
    var restaurantFilter: FilterModel?
    
    let starredRef = Database.database().reference(withPath: Constants.StarredRestaurants)
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restaurantTableView.dataSource = self
        restaurantTableView.delegate = self
        
        // default location to Edmonton in case location services not enabled
        let camera = GMSCameraPosition.camera(withLatitude: 53.544406, longitude: -113.490915, zoom: 9.0)
        mapView.camera = camera
        
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 50
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        // Fetch restaurants from the Firebase database
        restaurantRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                for (key, restaurantDict) in snapshot.value as! [String: NSDictionary] {
                    let restaurant = RestaurantModel(nsdictionary: restaurantDict)
                    restaurant.key = key
                    
                    // get restaurant rating if it exists
                    self.restaurantRatingsRef.child("\(restaurant.key)").observe(.value, with: { (snapshot) in
                        if(snapshot.exists()) {
                            restaurant.overallRating = RestaurantHelper.findOverallRestaurantRating(ratingModel: RatingModel(snapshot: snapshot))
                        }
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                    //self.calculateRestaurantDistances()
                    
                    if !restaurant.photoUrl.isEmpty {
                        Alamofire.request(restaurant.photoUrl).responseImage { response in
                            if let restaurantImage = response.result.value {
                                restaurant.photo = restaurantImage
                            }
                            self.restaurants[key] = restaurant
                            self.restaurantsList.append(restaurant)
                            self.filteredRestaurantsList = self.restaurantsList
                            self.restaurantTableView.reloadData()
                            self.updateStarredRestaurants()
                        }
                    } else {
                        self.restaurants[key] = restaurant
                        self.restaurantsList.append(restaurant)
                        self.filteredRestaurantsList = self.restaurantsList
                        self.restaurantTableView.reloadData()
                        self.updateStarredRestaurants()
                    }
                    self.showMarker(position: CLLocationCoordinate2D(latitude: (restaurant.lat as NSString).doubleValue, longitude: (restaurant.lng as NSString).doubleValue), title: restaurant.name, snippet: restaurant.address1, restaurantId: restaurant.key)
                }
            }
        })
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.enablesReturnKeyAutomatically = false
        self.restaurantTableView.tableHeaderView = searchController.searchBar
        self.definesPresentationContext = true
        
        // keep track of which restaurants are starred
        if let user = self.user {
            let userStarredRestaurantRef = Database.database().reference(withPath: "starredRestaurants/\(user.uid)")
            userStarredRestaurantRef.observe(DataEventType.value, with: { (snapshot) in
                self.starredDict = snapshot.value as? [String : Int] ?? [:]
                for restaurant in self.restaurantsList {
                    if self.starredDict[restaurant.key] == 1 {
                        restaurant.isStarredByCurrentUser = true
                    } else {
                        restaurant.isStarredByCurrentUser = false
                    }
                }
                self.restaurantTableView.reloadData()
            })
        }
        scheduledTimerWithTimeInterval()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // filtering will occur here
    }

    
    func showMarker(position: CLLocationCoordinate2D, title: String, snippet: String, restaurantId: String){
        let marker = GMSMarker()
        marker.position = position
        marker.title = title
        marker.snippet = snippet
        marker.icon=self.imageWithImage(image: UIImage(named: "carrotmapmarkeredibly")!, scaledToSize: CGSize(width: 27.0, height: 56.0))
        marker.userData = restaurantId
        marker.map = mapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        tappedIconRestaurant = restaurants[marker.userData as! String]
        self.performSegue(withIdentifier: "showRestaurantFromMap", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "openSettingsFromHomeScreen" {
            // perform any custom actions here
        } else if segue.identifier == "showRestaurantFromMap" {
            guard let restaurantViewController = segue.destination as? RestaurantViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            restaurantViewController.restaurant = tappedIconRestaurant
        } else if segue.identifier == "mapRestaurantCellTapped" {
            guard let restaurantViewController = segue.destination as? RestaurantViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedRestaurantCell = sender as? MapRestaurantTableViewCell else {
                fatalError("Unexpected sender")
            }
            
            guard let indexPath = restaurantTableView.indexPath(for: selectedRestaurantCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedRestaurant = filteredRestaurantsList[indexPath.row]
            restaurantViewController.restaurant = selectedRestaurant
            restaurantTableView.deselectRow(at: indexPath, animated: true)
        } else if segue.identifier == "showFilter" {
            guard let filterRestaurantViewController = segue.destination as? FilterRestaurantViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            filterRestaurantViewController.restaurantFilter = restaurantFilter
            filterRestaurantViewController.delegate = self
        }
        dismissKeyboard()
    }
    
    // MARK: Search Result Functions
    func updateSearchResults(for searchController: UISearchController) {
        // If we haven't typed anything into the search bar then do not filter the results
        if searchController.searchBar.text! == "" {
            filteredRestaurantsList = restaurantsList
        } else {
            // Filter the results
            filteredRestaurantsList = restaurantsList.filter {$0.name.lowercased().contains(searchController.searchBar.text!.lowercased())}
        }
        
        self.restaurantTableView.reloadData()
    }
    
    // MARK: Table View Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRestaurantsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MapRestaurantCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MapRestaurantTableViewCell  else {
            fatalError("The dequeued cell is not an instance of RestaurantTableViewCell.")
        }
        cell.delegate = self
        // Fetches the appropriate meal for the data source layout.
        let restaurant = filteredRestaurantsList[indexPath.row]
        cell.nameLabel.text = restaurant.name
        cell.addressLabel.text = restaurant.address1
        cell.restaurantImageView.image = restaurant.photo
        if restaurant.distanceFromUser != nil {
            cell.restaurantDistanceLabel.text = restaurant.distanceFromUser
        } else {
            cell.restaurantDistanceLabel.text = ""
        }
        
        if restaurant.overallRating == nil {
            cell.ratingProgressView.isHidden = true
            cell.ratingPercentageLabel.isHidden = true
            cell.ratingStaticLabel.isHidden = true
        } else {
            cell.ratingProgressView.isHidden = false
            cell.ratingPercentageLabel.isHidden = false
            cell.ratingStaticLabel.isHidden = false
            cell.ratingProgressView.progress = restaurant.overallRating!
            cell.ratingPercentageLabel.text = RestaurantHelper.convertRatingToStringPercentage(rating: restaurant.overallRating!)
        }
        
        var tags = ""
        for tag in restaurant.tags {
            if tags == "" {
                tags = tag.capitalized
            } else {
                tags = tags + ", " + tag.capitalized
            }
        }
        cell.tagsLabel.text = tags
        
        if restaurant.isStarredByCurrentUser {
            cell.starButton.setImage(UIImage(named: "starselected"), for: UIControlState.normal)
        } else {
            cell.starButton.setImage(UIImage(named: "starunselected"), for: UIControlState.normal)
        }
        return cell
    }
    
    // star button tapped
    func buttonTapped(cell: MapRestaurantTableViewCell) {
        guard let indexPath = restaurantTableView.indexPath(for: cell) else {
            return
        }
        let restaurant = restaurantsList[indexPath.row]
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
        for restaurant in restaurantsList {
            if starredDict[restaurant.key] == 1 {
                restaurant.isStarredByCurrentUser = true
            } else {
                restaurant.isStarredByCurrentUser = false
            }
        }
        self.restaurantTableView.reloadData()
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        searchController.searchBar.endEditing(true)
        //view.endEditing(true)
    }
    
    @IBAction func filterButtonTapped(_ sender: UIBarButtonItem) {
        dismissKeyboard()
        searchController.isActive = false
    }
    
    @objc func calculateRestaurantDistances() {
        if userCurrentLocation == nil || isLocationEnabled == false {
            return
        }

        for restaurant in restaurantsList {
            if restaurant.distanceFromUser == nil {
                let distanceFromUserInMeters = MapHelper.findDistanceFromCurrentLocation(lat: restaurant.lat, long: restaurant.lng, currentLocation: userCurrentLocation!)
                let df = MKDistanceFormatter()
                df.unitStyle = .abbreviated
                if distanceFromUserInMeters != nil {
                    restaurant.distanceFromUser = df.string(fromDistance: distanceFromUserInMeters!)
                    restaurant.distanceFromUserInKm = Float(distanceFromUserInMeters! / 1000)
                    self.restaurantTableView.reloadData()
                }
            }
        }
        
        elapsedTime += 1
        if elapsedTime > maxElapsedTime {
            timer.invalidate()
        }
        
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to calculate distance with the interval of 0.5 seconds for a max of 10 seconds
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(MapViewController.calculateRestaurantDistances), userInfo: nil, repeats: true)
    }
    
    // MARK: Filter functions
    
    // filter information is passed - filter restaurants and clear search
    func pass(data: FilterModel?) {
        self.restaurantFilter = data
        // check if filter is enabled //filter {$0.name.lowercased().contains(searchController.searchBar.text!.lowercased())}
        if restaurantFilter != nil && restaurantFilter!.isActive {
            filteredRestaurantsList = []
            
            for restaurant in restaurantsList {
                var includeRestaurantOnScreen = true
                
                if restaurantFilter!.minimumRating != nil {
                    if restaurant.overallRating == nil || (restaurant.overallRating! * 100) < Float(restaurantFilter!.minimumRating!) {
                        includeRestaurantOnScreen = false
                    }
                }
                
                if restaurantFilter!.maximumDistance != nil {
                    if restaurant.distanceFromUserInKm == nil || restaurant.distanceFromUserInKm! > Float(restaurantFilter!.maximumDistance!) {
                        includeRestaurantOnScreen = false
                    }
                }
                
                if includeRestaurantOnScreen {
                    filteredRestaurantsList.append(restaurant)
                }
            }
        } else {
            filteredRestaurantsList = restaurantsList
        }
        self.restaurantTableView.reloadData()
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    

}

extension MapViewController: GMSMapViewDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
            self.isLocationEnabled = true
            break
            
        case .denied, .restricted:
//            self.disableLocationRelatedFeatures()
            self.isLocationEnabled = false
            break
            
        // Do nothing otherwise.
        default: break
        }

        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }

        userCurrentLocation = location
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        locationManager.stopUpdatingLocation()
    }
    // put nothing here
}

protocol receivesFilterModelData {
    func pass(data: FilterModel?)
}

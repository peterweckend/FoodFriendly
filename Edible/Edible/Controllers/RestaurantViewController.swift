    //
//  RestaurantViewController.swift

import UIKit
import Firebase

class RestaurantViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var dishes = [DishModel]()
    var reviews = [ReviewModel]()
    var isStarred = false
    let storage = Storage.storage()
    var restaurantPreviewImageNames = [String]()
    var restaurantTips = [RestaurantTipModel]()
    var tags = ""
    let imagePickerController = UIImagePickerController()
    var isTopTipDisplayed = false // just display the first tip that loads
    
    @IBOutlet weak var restaurantRatingProgressView: UIProgressView!
    @IBOutlet weak var ratingPercentage: UILabel!
    @IBOutlet weak var ratingStaticLabel: UILabel!
    @IBOutlet weak var dishesTableView: UITableView!
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantAddressLabel: UILabel!
    @IBOutlet weak var restaurantTagsLabel: UILabel!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var tipTextLabel: UILabel!
    //@IBOutlet weak var starText: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var numberOfPhotosLabel: UILabel!
    @IBOutlet weak var photosTextLabel: UILabel!
    @IBOutlet weak var restaurantPhotoAImageView: UIImageView!
    @IBOutlet weak var restaurantPhotoBImageView: UIImageView!
    @IBOutlet weak var restaurantPhotoCImageView: UIImageView!
    @IBOutlet weak var seeAllTipsButton: UIButton!
    @IBOutlet weak var tipUserLabel: UILabel!
    
    let restaurantTipsRef = Database.database().reference(withPath: Constants.RestaurantTips)
    
    var imageCount : Int = 0 {
        didSet{
            if imageCount == 1 {
                photosTextLabel.text = "photo"
            } else {
                photosTextLabel.text = "photos"
            }
            numberOfPhotosLabel.text = String(imageCount)
        }
    }
    lazy var restaurantPhotoImageViews = {
        return [restaurantPhotoAImageView, restaurantPhotoBImageView, restaurantPhotoCImageView]
    }()
    
    let user = Auth.auth().currentUser
    
    // this value will be passed by the RestaurantTableViewController
    var restaurant: RestaurantModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        dishesTableView.dataSource = self
        dishesTableView.delegate = self
        dishesTableView.register(UITableViewCell.self, forCellReuseIdentifier:  "cell")
        
        reviewTableView.dataSource = self
        reviewTableView.delegate = self
        reviewTableView.register(UITableViewCell.self, forCellReuseIdentifier: "reviewCell")
        
        seeAllTipsButton.isEnabled = false
        seeAllTipsButton.isHidden = true
        
        restaurantPhotoAImageView.image = UIImage(named: "(Apple)NoImageSelected")
        restaurantPhotoBImageView.image = UIImage(named: "(Apple)NoImageSelected")
        restaurantPhotoCImageView.image = UIImage(named: "(Apple)NoImageSelected")
        
        let tapGestureRecognizerA = UITapGestureRecognizer(target: self, action: #selector(RestaurantViewController.restaurantImageTapped(_:)))
        restaurantPhotoAImageView.addGestureRecognizer(tapGestureRecognizerA)
        
        let tapGestureRecognizerB = UITapGestureRecognizer(target: self, action: #selector(RestaurantViewController.restaurantImageTapped(_:)))
        restaurantPhotoBImageView.addGestureRecognizer(tapGestureRecognizerB)
        
        let tapGestureRecognizerC = UITapGestureRecognizer(target: self, action: #selector(RestaurantViewController.restaurantImageTapped(_:)))
        restaurantPhotoCImageView.addGestureRecognizer(tapGestureRecognizerC)
        
        if let restaurant = restaurant {
            navigationItem.title = restaurant.name
            restaurantNameLabel.text = restaurant.name
            restaurantAddressLabel.text = restaurant.address1
            if restaurant.photo == nil {
                print("image is null")
            }
            restaurantImageView.image = restaurant.photo
            
            for tag in restaurant.tags {
                if tags == "" {
                    tags = tag.capitalized
                } else {
                    tags = tags + ", " + tag.capitalized
                }
            }
            restaurantTagsLabel.text = tags

            } else {
            fatalError("Restaurant failed to load properly")
        }
        
        // assert: the passed in restaurant should already have a rating
        // load rating for restaurant restaurantRatingProgressView
        if restaurant!.overallRating == nil {
            restaurantRatingProgressView.isHidden = true
            ratingPercentage.isHidden = true
            ratingStaticLabel.isHidden = true
        } else {
            restaurantRatingProgressView.isHidden = false
            ratingPercentage.isHidden = false
            ratingStaticLabel.isHidden = false
            restaurantRatingProgressView.progress = restaurant!.overallRating!
            ratingPercentage.text = RestaurantHelper.convertRatingToStringPercentage(rating: restaurant!.overallRating!)
        }
        
        // check if restaurant is starred and perform proper actions
        let starredRef = Database.database().reference(withPath: Constants.StarredRestaurants)
        if let user = self.user {
            let uid = user.uid
            starredRef.child("\(uid)/\(restaurant!.key)").observe(DataEventType.value, with: { (snapshot) in
                var isStarred = false
                if snapshot.exists() {
                    isStarred = snapshot.value as! Bool
                }
                if isStarred {
                    self.starButton.setImage(UIImage(named: "starrestaurantview"), for: UIControlState.normal)
                    //self.starText.text = "Unstar"
                } else {
                    self.starButton.setImage(UIImage(named: "starbuttonunselected"), for: UIControlState.normal)
                    //self.starText.text = "Star"
                }
            })
        }
        
        // only want dishes for the loaded restaurant
        let dishesRef = Database.database().reference(withPath: "dishes/\(restaurant!.key)")
        let dishRatingRef = Database.database().reference(withPath: Constants.DishRatings)
        
        // Listen for new dishes in the Firebase database
        // should be something like ref.queryby... .observe
        dishesRef.observe(.childAdded, with: { (snapshot) -> Void in
            let dish = DishModel(snapshot: snapshot)
            
            // get dish rating if it exists
            dishRatingRef.child("\(self.restaurant!.key)/\(dish.key)").observe(.value, with: { (snapshot) in
                if(snapshot.exists()) {
                    dish.overallRating = RestaurantHelper.findOverallDishRating(ratingModel: DishRatingModel(snapshot: snapshot))
                    self.dishesTableView.reloadData()
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
            self.dishes.append(dish)
            self.dishesTableView.reloadData()
        })
        
        let reviewRef = Database.database().reference(withPath: "reviews/\(restaurant!.key)")
        reviewRef.observe(.childAdded, with: { (snapshot) -> Void in
            let review = ReviewModel(snapshot: snapshot)
            self.reviews.append(review)
            self.reviewTableView.reloadData()
        })
        
        let restaurantPicsRef = Database.database().reference(withPath: "restaurantImages/\(restaurant!.key)")
        restaurantPicsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.imageCount = Int(snapshot.childrenCount)
        }) { (error) in
            print(error.localizedDescription)
        }
        
    restaurantTipsRef.child(restaurant!.key).observe(.childAdded, with: { (snapshot) -> Void in
            let tip = RestaurantTipModel(snapshot: snapshot)
            self.restaurantTips.append(tip)
            if !self.isTopTipDisplayed {
                self.tipTextLabel.text = tip.description
                self.isTopTipDisplayed = true
                self.seeAllTipsButton.isEnabled = true
                self.seeAllTipsButton.isHidden = false
                
                let userProfileRef = Database.database().reference(withPath: "userProfiles/\(tip.tipUserId)")
                userProfileRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    let userProfile = UserProfileModel(snapshot: snapshot)
                    self.tipUserLabel.text = "-" + userProfile.firstName + " " + userProfile.lastName
                })
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        let restaurantPreviewPicsRef = Database.database().reference(withPath: "restaurantImages/\(restaurant!.key)").queryLimited(toFirst: 3)
        restaurantPreviewPicsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if !(snapshot.value is NSNull) && snapshot.exists() {
                for (_, element) in snapshot.value as! [String: String] {
                    self.restaurantPreviewImageNames.append(element)
                }
                if self.restaurantPreviewImageNames.count == 3 {
                    let restaurantPreviewPicRefA = self.storage.reference().child("restaurants/\(self.restaurant!.key)/\(self.restaurantPreviewImageNames[0])")
                    // max size 12MB
                    restaurantPreviewPicRefA.getData(maxSize: 12 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error)
                        } else {
                            self.restaurantPhotoAImageView.image = UIImage(data: data!)
                        }
                    }
                    
                    let restaurantPreviewPicRefB = self.storage.reference().child("restaurants/\(self.restaurant!.key)/\(self.restaurantPreviewImageNames[1])")
                    restaurantPreviewPicRefB.getData(maxSize: 12 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error)
                        } else {
                            self.restaurantPhotoBImageView.image = UIImage(data: data!)
                        }
                    }
                    
                    let restaurantPreviewPicRefC = self.storage.reference().child("restaurants/\(self.restaurant!.key)/\(self.restaurantPreviewImageNames[2])")
                    restaurantPreviewPicRefC.getData(maxSize: 12 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error)
                        } else {
                            self.restaurantPhotoCImageView.image = UIImage(data: data!)
                        }
                    }
                    
                    
                } else if self.restaurantPreviewImageNames.count == 2 {
                    let restaurantPreviewPicRefA = self.storage.reference().child("restaurants/\(self.restaurant!.key)/\(self.restaurantPreviewImageNames[0])")
                    // max size 12MB
                    restaurantPreviewPicRefA.getData(maxSize: 12 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error)
                        } else {
                            self.restaurantPhotoAImageView.image = UIImage(data: data!)
                        }
                    }
                    
                    let restaurantPreviewPicRefB = self.storage.reference().child("restaurants/\(self.restaurant!.key)/\(self.restaurantPreviewImageNames[1])")
                    restaurantPreviewPicRefB.getData(maxSize: 12 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error)
                        } else {
                            self.restaurantPhotoBImageView.image = UIImage(data: data!)
                        }
                    }
                } else if self.restaurantPreviewImageNames.count == 1 {
                    let restaurantPreviewPicRefA = self.storage.reference().child("restaurants/\(self.restaurant!.key)/\(self.restaurantPreviewImageNames[0])")
                    // max size 12MB
                    restaurantPreviewPicRefA.getData(maxSize: 12 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error)
                        } else {
                            self.restaurantPhotoAImageView.image = UIImage(data: data!)
                        }
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        // .queryOrderedByKey()
        
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "writeNewReview" {
            guard let writeReviewViewController = segue.destination as? WriteReviewViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            writeReviewViewController.restaurantId = restaurant?.key
            writeReviewViewController.restaurantName = restaurant?.name
        } else if segue.identifier == "showAllRestaurantPhotos" {
            guard let restaurantPhotosCollectionViewController = segue.destination as? RestaurantPhotosCollectionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            restaurantPhotosCollectionViewController.restaurant = restaurant
            restaurantPhotosCollectionViewController.passedImageCount = imageCount
        } else if segue.identifier == "viewDishes" {
            guard let restaurantMenuViewController = segue.destination as? RestaurantMenuViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            restaurantMenuViewController.restaurantId = restaurant?.key
            restaurantMenuViewController.restaurantName = restaurant?.name
        } else if segue.identifier == "addTipSegue" {
            guard let addRestaurantTipViewController = segue.destination as? AddRestaurantTipViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            addRestaurantTipViewController.restaurantId = restaurant?.key
            addRestaurantTipViewController.restaurantName = restaurant?.name
        } else if segue.identifier == "seeAllTipsSegue" {
            guard let tipsTableViewController = segue.destination as? TipsTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            tipsTableViewController.restaurantTips = restaurantTips
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?
        
        if tableView == self.dishesTableView {
            count = dishes.count
        } else {
            count = reviews.count
        }
        
        return count!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.dishesTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantDishTableViewCell", for: indexPath) as? RestaurantDishTableViewCell else {
                fatalError("The dequeued cell is not an instance of RestaurantTableViewCell")
            }
            let dishItem = dishes[indexPath.row]
            cell.dishTitle.text = dishItem.name
            cell.dishDescription.text = dishItem.description
            // am i looking at the wrong model for the below items?
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
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantReviewTableViewCell", for: indexPath) as? RestaurantReviewTableViewCell else {
                fatalError("The dequeued cell is not an instance of RestaurantReviewTableViewCell")
            }
            let reviewItem = reviews[indexPath.row]
            let userProfileRef = Database.database().reference(withPath: "userProfiles/\(reviewItem.reviewingUserId)")
            userProfileRef.observe(DataEventType.value, with: { (snapshot) in
                let userProfile = UserProfileModel(snapshot: snapshot)
                cell.reviewerName.text = userProfile.firstName + " " + userProfile.lastName.prefix(1)
                
                let userProfilePicRef = self.storage.reference().child("users/\( reviewItem.reviewingUserId)/profilePicture.jpg")
//                // max size 6MB
                userProfilePicRef.getData(maxSize: 6 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error)
                    } else {
                        cell.userPhoto.image = UIImage(data: data!)
                    }
                }
            })
            
            cell.reviewDescription.text = reviewItem.description

            if reviewItem.isFoodGood == nil {
                cell.foodRatingLabel.text = ""
                cell.foodRatingImage.image = nil
            } else if reviewItem.isFoodGood == true {
                cell.foodRatingImage.image = UIImage(named: "starrestaurantview")
            } else {
                cell.foodRatingImage.image = UIImage(named: "starbuttonunselected")
            }
            
            if reviewItem.isAtmosphereGood == nil {
                cell.atmosphereRatingLabel.text = ""
                cell.atmosphereRatingImage.image = nil
            } else if reviewItem.isAtmosphereGood == true {
                cell.atmosphereRatingImage.image = UIImage(named: "starrestaurantview")
            } else {
                cell.atmosphereRatingImage.image = UIImage(named: "starbuttonunselected")
            }
            
            if reviewItem.isEdibilityGood == nil {
                cell.edibleRatingLabel.text = ""
                cell.edibleRatingImage.image = nil
            } else if reviewItem.isEdibilityGood == true {
                cell.edibleRatingImage.image = UIImage(named: "starrestaurantview")
            } else {
                cell.edibleRatingImage.image = UIImage(named: "starbuttonunselected")
            }
            
            
            
            return cell
        }
        
    }
    
    @IBAction func starButtonToggled(_ sender: UIButton) {
        let starredRef = Database.database().reference(withPath: Constants.StarredRestaurants)
        if let user = self.user {
            let uid = user.uid
            if isStarred {
                // unstar the restaurant
                starredRef.child("\(uid)/\(self.restaurant!.key)").setValue(0)
                self.starButton.setImage(UIImage(named: "starbuttonunselected"), for: UIControlState.normal)
                //self.starText.text = "Star"
                isStarred = false
            } else {
                // star the restaurant
                starredRef.child("\(uid)/\(self.restaurant!.key)").setValue(1)
                self.starButton.setImage(UIImage(named: "starrestaurantview"), for: UIControlState.normal)
                //self.starText.text = "Unstar"
                isStarred = true
            }
        }
    }
    
    @IBAction func reviewButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "writeNewReview", sender: self)
    }
    
    @IBAction func addPhotoButtonClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraRollAction = UIAlertAction(title: "Choose from camera roll", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.sourceType = .photoLibrary;
            self.imagePickerController.allowsEditing = true
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        alertController.addAction(cameraRollAction)
        
        let takePictureAction = UIAlertAction(title: "Take a picture", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
            self.imagePickerController.cameraCaptureMode = .photo
            self.imagePickerController.modalPresentationStyle = .fullScreen
            self.present(self.imagePickerController,
                                       animated: true,
                                       completion: nil)
        }
        alertController.addAction(takePictureAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
        
    }
    
    @IBAction func AddTipButtonClicked(_ sender: UIButton) {
         self.performSegue(withIdentifier: "addTipSegue", sender: self)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
        
        let restaurantPhotoRef = Database.database().reference(withPath: "restaurantImages/\(restaurant!.key)")

        // generate universally unique id for photo name
        let uuid = UUID().uuidString
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        if imageCount < 3 {
            restaurantPhotoImageViews[imageCount]?.image = selectedImage
        }
        imageCount += 1
        
        let restaurantPicsRef = storage.reference().child("restaurants/\(restaurant!.key)/\(uuid).jpg")
        if let restaurantImage = UIImagePNGRepresentation(selectedImage.resizedTo2MB()!) {
            restaurantPicsRef.putData(restaurantImage, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                restaurantPhotoRef.child(uuid).setValue(metadata?.name)

            })
        }

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    @objc func restaurantImageTapped(_ sender:AnyObject) {
        if restaurantPreviewImageNames.count != 0 { // could use image count but might cause issues
            self.performSegue(withIdentifier: "showAllRestaurantPhotos", sender: self)
        }
    }
    
    
    @IBAction func seeAllDishesClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "viewDishes", sender: self)
    }
    
    func calculateRestaurantRating(restaurant:RestaurantModel) -> Float {
        
        return 1
    }

    @IBAction func seeAllTipsPressed(_ sender: UIButton) {
        if restaurantTips.count != 0 {
            self.performSegue(withIdentifier: "seeAllTipsSegue", sender: self)
        }
    }
    
    

}
    
extension UIImage {
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedTo2MB() -> UIImage? {
        guard let imageData = UIImagePNGRepresentation(self) else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1000.0
        
        while imageSizeKB > 2000 {
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
                let imageData = UIImagePNGRepresentation(resizedImage)
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1000.0
        }
        
        return resizingImage
    }
}

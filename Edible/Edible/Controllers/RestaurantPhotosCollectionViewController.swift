//
//  RestaurantPhotosCollectionViewController.swift

import UIKit
import Firebase

private let reuseIdentifier = "restaurantCell"

class RestaurantPhotosCollectionViewController: UICollectionViewController {

    let storage = Storage.storage()
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    var restaurant: RestaurantModel?
    var passedImageCount: Int? // currently unused
    var restaurantImageNames = [String]()
    var restaurantImages = [UIImage]()
    @IBOutlet var restaurantCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(RestaurantPhotoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        navigationItem.title = "Photos"

        // For now, max number of photos is 50 for a restaurant
        let restaurantPreviewPicsRef = Database.database().reference(withPath: "restaurantImages/\(restaurant!.key)").queryLimited(toFirst: 50)
        restaurantPreviewPicsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // fetch image names for download
            for (_, element) in snapshot.value as! [String: String] {
                self.restaurantImageNames.append(element)
            }
            
            // fetch images
            for imageName in self.restaurantImageNames {
                let restaurantPicRef = self.storage.reference().child("restaurants/\(self.restaurant!.key)/\(imageName)")
                // max size 12MB
                restaurantPicRef.getData(maxSize: 12 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error)
                    } else {
                        self.restaurantImages.append(UIImage(data: data!)!)
                        self.restaurantCollectionView.reloadData()
                    }
                }
            }
            // refresh the collection view
            self.restaurantCollectionView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantImage" {
            guard let restaurantIndividualImageViewController = segue.destination as? RestaurantIndividualImageViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedRestaurantImageCell = sender as? RestaurantPhotoCollectionViewCell else {
                fatalError("Unexpected sender")
            }
            
            guard let indexPath = self.restaurantCollectionView.indexPath(for: selectedRestaurantImageCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedImage = restaurantImages[indexPath.row]
            restaurantIndividualImageViewController.restaurantImageViewSource = selectedImage
            restaurantIndividualImageViewController.restaurant = restaurant
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return restaurantImageNames.count
//        if passedImageCount != nil {
//            return passedImageCount!
//        } else {
//            return 0
//        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RestaurantPhotoCollectionViewCell

        if restaurantImages.indices.contains(indexPath.row) {
            let restaurantImage = restaurantImages[indexPath.row]
            cell.cellImageView.image = restaurantImage
        }
        else {
            // use default image
            cell.cellImageView.image = UIImage(named: "(Apple)NoImageSelected")
        }

        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

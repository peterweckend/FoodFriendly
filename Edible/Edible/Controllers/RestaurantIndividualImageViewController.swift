//
//  RestaurantIndividualImageViewController.swift

import UIKit

class RestaurantIndividualImageViewController: UIViewController {

    @IBOutlet weak var restaurantImageView: UIImageView!
    var restaurantImageViewSource: UIImage?
    var restaurant: RestaurantModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if restaurantImageViewSource != nil {
            restaurantImageView.image = restaurantImageViewSource
        }
        if restaurant != nil {
            navigationItem.title = restaurant?.name
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

}

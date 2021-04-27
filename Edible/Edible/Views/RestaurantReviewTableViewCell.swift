//
//  RestaurantReviewTableViewCell.swift

import UIKit

class RestaurantReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reviewerName: UILabel!
    @IBOutlet weak var reviewDescription: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var foodRatingImage: UIImageView!
    @IBOutlet weak var atmosphereRatingImage: UIImageView!
    @IBOutlet weak var edibleRatingImage: UIImageView!
    @IBOutlet weak var foodRatingLabel: UILabel!
    @IBOutlet weak var atmosphereRatingLabel: UILabel!
    @IBOutlet weak var edibleRatingLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

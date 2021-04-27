//
//  UserProfileReviewTableViewCell.swift
//  Edible

import UIKit

class UserProfileReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var reviewDescription: UILabel!
    @IBOutlet weak var foodRatingImageView: UIImageView!
    @IBOutlet weak var foodRatingLabel: UILabel!
    @IBOutlet weak var atmosphereRatingImageView: UIImageView!
    @IBOutlet weak var atmosphereRatingLabel: UILabel!
    @IBOutlet weak var edibleRatingImageView: UIImageView!
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

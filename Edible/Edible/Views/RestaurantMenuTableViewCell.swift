//
//  RestaurantMenuTableViewCell.swift
//  Edible

import UIKit

class RestaurantMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var dishTitleLabel: UILabel!
    @IBOutlet weak var dishDescriptionLabel: UILabel!
    @IBOutlet weak var dishRatingProgressView: UIProgressView!
    @IBOutlet weak var dishRatingLabel: UILabel!
    @IBOutlet weak var dishRatingStaticLabel: UILabel!
    @IBOutlet weak var dishDietImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

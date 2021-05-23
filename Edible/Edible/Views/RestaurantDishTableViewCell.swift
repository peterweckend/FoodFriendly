//
//  RestaurantDishTableViewCell.swift

import UIKit

class RestaurantDishTableViewCell: UITableViewCell {

    @IBOutlet weak var dishTitle: UILabel!
    @IBOutlet weak var dishDescription: UILabel!
    @IBOutlet weak var dishRatingProgressView: UIProgressView!
    @IBOutlet weak var dishRatingLabel: UILabel!
    @IBOutlet weak var dishRatingStaticLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  RestaurantTipsTableViewCell.swift
//  Edible

import UIKit

class RestaurantTipsTableViewCell: UITableViewCell {

    @IBOutlet weak var tipTextLabel: UILabel!
    @IBOutlet weak var tipUserLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  RestaurantTableViewCell.swift
//
//  This takes care of each Restaurant row in the Home screen.

import UIKit

protocol RestaurantTableViewCellDelegate: class {
    func buttonTapped(cell: RestaurantTableViewCell)
}

class RestaurantTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var restaurantProgressView: UIProgressView!
    @IBOutlet weak var reviewPercentLabel: UILabel!
    @IBOutlet weak var reviewStaticLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    
    
    var delegate: RestaurantTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    @IBAction func restaurantStarred(_ sender: UIButton) {
        self.delegate?.buttonTapped(cell: self)
    }
    

}

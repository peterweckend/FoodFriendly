//
//  StarredRestaurantTableViewCell.swift

import UIKit

protocol StarredRestaurantTableViewCellDelegate: class {
    func buttonTapped(cell: StarredRestaurantTableViewCell)
}

class StarredRestaurantTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var ratingProgressView: UIProgressView!
    @IBOutlet weak var ratingPercentage: UILabel!
    @IBOutlet weak var ratingStaticLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    var delegate: StarredRestaurantTableViewCellDelegate?
    
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
    
    @IBAction func starButtonToggled(_ sender: Any) {
        self.delegate?.buttonTapped(cell: self)
    }
    
    

}

//
//  MapRestaurantTableViewCell.swift
//  Edible

import UIKit

class MapRestaurantTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var ratingProgressView: UIProgressView!
    @IBOutlet weak var ratingPercentageLabel: UILabel!
    @IBOutlet weak var ratingStaticLabel: UILabel!
    @IBOutlet weak var restaurantDistanceLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    var delegate: StarredMapTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func starButtonToggled(_ sender: UIButton) {
        self.delegate?.buttonTapped(cell: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
}

protocol StarredMapTableViewCellDelegate: class {
    func buttonTapped(cell: MapRestaurantTableViewCell)
}

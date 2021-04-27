//
//  FilterRestaurantViewController.swift
//  Edible

import UIKit

class FilterRestaurantViewController: UIViewController {
    
    var restaurantFilter: FilterModel?
    @IBOutlet weak var ratingValueLabel: UILabel!
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var removeFilterButton: UIButton!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var distanceSlider: UISlider!
    var delegate: receivesFilterModelData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if restaurantFilter != nil && restaurantFilter!.isActive == true {
            removeFilterButton.isHidden = false
            if restaurantFilter?.minimumRating != nil {
                ratingSlider.value = Float(restaurantFilter!.minimumRating!)
            }
            if restaurantFilter?.maximumDistance != nil {
                distanceSlider.value = Float(restaurantFilter!.maximumDistance!)
            }
        } else {
            removeFilterButton.isHidden = true
            ratingSlider.value = 0
            distanceSlider.value = 30
        }
        
        updateRatingSliderLabel()
        updateDistanceSliderLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - Actions
    @IBAction func removeFilterButtonPressed(_ sender: UIButton) {
        delegate?.pass(data: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        var minimumRating: Int? = nil
        var maximumDistance: Int? = nil
        
        if ratingSlider.value.rounded() != 0 {
            minimumRating = Int(ratingSlider.value.rounded())
        }
        if distanceSlider.value.rounded() != 30 {
            maximumDistance = Int(distanceSlider.value.rounded())
        }
        
        if minimumRating == nil && maximumDistance == nil {
            // no filter was created
            delegate?.pass(data: nil)
        } else {
            restaurantFilter = FilterModel(isActive: true, minimumRating: minimumRating, maximumDistance: maximumDistance)
            
            delegate?.pass(data: restaurantFilter!)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ratingSliderChanged(_ sender: UISlider) {
        updateRatingSliderLabel()
    }
    
    @IBAction func distanceSliderChanged(_ sender: UISlider) {
        updateDistanceSliderLabel()
    }
    
    func updateRatingSliderLabel() {
        if ratingSlider.value.rounded() == 0 {
            ratingValueLabel.text = "Any rating"
        } else {
            ratingValueLabel.text = "\(Int(ratingSlider.value.rounded()))% or above"
        }
    }
    
    func updateDistanceSliderLabel() {
        if distanceSlider.value.rounded() == 30 {
            distanceValueLabel.text = "Any distance"
        } else {
            distanceValueLabel.text = "Less than \(Int(distanceSlider.value.rounded())) km away"
        }
    }
    
}



//
//  WriteReviewViewController.swift

import UIKit
import Firebase

class WriteReviewViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var restaurantId: String?
    var restaurantName: String?
    let reviewsRef = Database.database().reference(withPath: Constants.Reviews)
    let reviewsByUserRef = Database.database().reference(withPath: Constants.ReviewsByUser)
    let restaurantRatingsRef = Database.database().reference(withPath: Constants.RestaurantRatings)
    let generator = UIImpactFeedbackGenerator(style: .light)
    //var imageAdded = false
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var reviewDescription: UITextView!
    //@IBOutlet weak var reviewImageView: UIImageView!
    
    @IBOutlet weak var isFoodGoodTrueButton: UIButton!
    @IBOutlet weak var isFoodGoodFalseButton: UIButton!
    
    @IBOutlet weak var isAtmosphereGoodTrueButton: UIButton!
    @IBOutlet weak var isAtmosphereGoodFalseButton: UIButton!
    
    @IBOutlet weak var isEdibilityGoodTrueButton: UIButton!
    @IBOutlet weak var isEdibilityGoodFalseButton: UIButton!
    @IBOutlet weak var reviewTitleLabel: UILabel!
    
    
    
    var review: ReviewModel?
    var reviewByUser: ReviewByUserModel?
    let user = Auth.auth().currentUser
    
    var isFoodGood : Bool? {
        didSet{
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.orange
            if isFoodGood! {
                // highlight the + button, clear the - button
                isFoodGoodTrueButton.setImage(UIImage(named: "thumbsuporange"), for: .normal)
                isFoodGoodFalseButton.setImage(UIImage(named: "thumbsdown"), for: .normal)
            } else {
                // highlight the - button, clear the + button
                isFoodGoodTrueButton.setImage(UIImage(named: "thumbsup"), for: .normal)
                isFoodGoodFalseButton.setImage(UIImage(named: "thumbsdownorange"), for: .normal)
            }
        }
    }
    
    var isAtmosphereGood : Bool? {
        didSet{
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.orange
            if isAtmosphereGood! {
                // highlight the + button, clear the - button
                isAtmosphereGoodTrueButton.setImage(UIImage(named: "thumbsuporange"), for: .normal)
                isAtmosphereGoodFalseButton.setImage(UIImage(named: "thumbsdown"), for: .normal)
            } else {
                // highlight the - button, clear the + button
                isAtmosphereGoodTrueButton.setImage(UIImage(named: "thumbsup"), for: .normal)
                isAtmosphereGoodFalseButton.setImage(UIImage(named: "thumbsdownorange"), for: .normal)
            }
        }
    }
    
    var isEdibilityGood : Bool? {
        didSet{
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.orange
            if isEdibilityGood! {
                // highlight the + button, clear the - button
                isEdibilityGoodTrueButton.setImage(UIImage(named: "thumbsuporange"), for: .normal)
                isEdibilityGoodFalseButton.setImage(UIImage(named: "thumbsdown"), for: .normal)
            } else {
                // highlight the - button, clear the + button
                isEdibilityGoodTrueButton.setImage(UIImage(named: "thumbsup"), for: .normal)
                isEdibilityGoodFalseButton.setImage(UIImage(named: "thumbsdownorange"), for: .normal)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFoodGood != nil || isAtmosphereGood != nil || isEdibilityGood != nil || !reviewDescription.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.orange
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.lightGray
        }

        if restaurantName != nil {
            reviewTitleLabel.text = "New Review for " + restaurantName!
        } else {
            reviewTitleLabel.text = "New Review"
        }
        // from https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WriteReviewViewController.dismissKeyboard))        
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        if isFoodGood != nil || isAtmosphereGood != nil || isEdibilityGood != nil || !reviewDescription.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.orange
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.lightGray
        }

        view.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addADishSegue" {
            let userId = user!.uid //TODO: make null safe
            let reviewDescriptionText = reviewDescription.text ?? ""
            review = ReviewModel(description: reviewDescriptionText, reviewingUserId: userId, isFoodGood: isFoodGood, isAtmosphereGood: isAtmosphereGood, isEdibilityGood: isEdibilityGood)
            reviewByUser = ReviewByUserModel(description: reviewDescriptionText, isFoodGood: isFoodGood, isAtmosphereGood: isAtmosphereGood, isEdibilityGood: isEdibilityGood, restaurantName: restaurantName!, restaurantKey: restaurantId!)
            
            guard let selectReviewDishViewController = segue.destination as? SelectReviewDishViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            selectReviewDishViewController.restaurantId = restaurantId
            selectReviewDishViewController.restaurantName = restaurantName
            selectReviewDishViewController.review = review
            selectReviewDishViewController.reviewByUser = reviewByUser
        }
    }
    
    @IBAction func addADishButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "addADishSegue", sender: self)
    }
    
    
    
    // MARK: - rating buttons
    
    @IBAction func foodGoodButtonClicked(_ sender: UIButton) {
        generator.impactOccurred()
        isFoodGood = true
    }
    
    @IBAction func foodBadButtonClicked(_ sender: UIButton) {
        generator.impactOccurred()
        isFoodGood = false
    }
    
    @IBAction func atmosphereGoodButtonClicked(_ sender: UIButton) {
        generator.impactOccurred()
        isAtmosphereGood = true
    }
    
    @IBAction func atmosphereBadButtonClicked(_ sender: UIButton) {
        generator.impactOccurred()
        isAtmosphereGood = false
    }
    
    @IBAction func edibilityGoodButtonClicked(_ sender: UIButton) {
        generator.impactOccurred()
        isEdibilityGood = true
    }
    
    @IBAction func edibilityBadButtonClicked(_ sender: UIButton) {
        generator.impactOccurred()
        isEdibilityGood = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        if isFoodGood != nil || isAtmosphereGood != nil || isEdibilityGood != nil || !reviewDescription.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.orange
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.lightGray
        }

        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // do something with the text entered into the text field
        
    }
    
    // MARK: - Photo methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
}

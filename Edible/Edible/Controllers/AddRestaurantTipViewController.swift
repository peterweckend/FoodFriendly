//
//  AddRestaurantTipViewController.swift
//  Edible

import UIKit
import Firebase

class AddRestaurantTipViewController: UIViewController {

    var tip: RestaurantTipModel?
    var restaurantId: String?
    var restaurantName: String?
    let user = Auth.auth().currentUser
    let restaurantTipsRef = Database.database().reference(withPath: Constants.RestaurantTips)
    @IBOutlet weak var tipTextView: UITextView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessageLabel.isHidden = true
        if restaurantId == nil {
            // an error occurred
            dismiss(animated: true, completion: nil)
        }
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WriteReviewViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        tipLabel.text = Constants.tipText + restaurantName!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) + "!"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func tipSubmitted(_ sender: UIButton) {
        if tipTextView.text.count > 140{
            errorMessageLabel.text = "Too many characters"
            errorMessageLabel.isHidden = false
            return
        } else if tipTextView.text.isEmpty || tipTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            errorMessageLabel.text = "Tip cannot be empty"
            errorMessageLabel.isHidden = false
            return
        } else {
            errorMessageLabel.isHidden = true
        }
        
        if let user = user {
            // create the tip
            tip = RestaurantTipModel(tipUserId: user.uid, description: tipTextView.text)
            let restaurantTipRef = restaurantTipsRef.child("\(restaurantId!)").childByAutoId()
            restaurantTipRef.setValue(tip?.toAnyObject())
        } else {
            // No User is signed in. Error occurred
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tipCancelled(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}

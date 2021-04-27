//
//  GlutenFreeViewController.swift

import UIKit

class GlutenFreeViewController: UIViewController {

    var selectedDiet: DietModel?
    var isGlutenFree: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isGlutenFree = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "dietGlutenOptionsSelected" {
            guard let signUpViewController = segue.destination as? SignUpViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            signUpViewController.selectedDiet = selectedDiet
            signUpViewController.isGlutenFree = isGlutenFree
        }
    }
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        isGlutenFree = true
        self.performSegue(withIdentifier: "dietGlutenOptionsSelected", sender: self)
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        isGlutenFree = false
        self.performSegue(withIdentifier: "dietGlutenOptionsSelected", sender: self)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

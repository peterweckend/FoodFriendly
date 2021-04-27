//
//  DietSelectionViewController.swift

import UIKit

class DietSelectionViewController: UIViewController {

    var selectedDiet = DietModel(name: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "dietSelectedSegue" {
            guard let glutenFreeViewController = segue.destination as? GlutenFreeViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            glutenFreeViewController.selectedDiet = selectedDiet
        }
        
    }
    
    
    @IBAction func vegetarianDietSelected(_ sender: UIButton) {
        selectedDiet!.name = "vegetarian"
        self.performSegue(withIdentifier: "dietSelectedSegue", sender: self)
    }
    
    @IBAction func veganDietSelected(_ sender: UIButton) {
        selectedDiet!.name = "vegan"
        self.performSegue(withIdentifier: "dietSelectedSegue", sender: self)
    }

    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

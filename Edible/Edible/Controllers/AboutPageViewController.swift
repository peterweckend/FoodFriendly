//
//  AboutPageViewController.swift
//  Edible
//  Shows information about app

import UIKit
import Crashlytics

class AboutPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func openCompanySite(_ sender: UIButton) {
        UIApplication.shared.open(NSURL(string:Constants.edibleURL)! as URL)
    }

}

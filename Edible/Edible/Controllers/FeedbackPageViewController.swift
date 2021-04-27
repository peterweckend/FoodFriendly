//
//  FeedbackPageViewController.swift
//  Edible
//  Allows the user to open a feedback form for the app

import UIKit

class FeedbackPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    @IBAction func addFeedbackPressed(_ sender: UIButton) {
        UIApplication.shared.open(NSURL(string:Constants.feedbackFormURL)! as URL)
    }
    
    
}

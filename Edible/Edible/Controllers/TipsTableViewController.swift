//
//  TipsTableViewController.swift
//  Edible

import UIKit
import Firebase

class TipsTableViewController: UITableViewController {

    var restaurantTips: [RestaurantTipModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        for tip in restaurantTips {
            let userProfileRef = Database.database().reference(withPath: "userProfiles/\(tip.tipUserId)")
            userProfileRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let userProfile = UserProfileModel(snapshot: snapshot)
                tip.userName = userProfile.firstName + " " + userProfile.lastName
                self.tableView.reloadData()
                })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurantTips.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TipCell", for: indexPath) as? RestaurantTipsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TipCell.")
        }
        let tip = restaurantTips[indexPath.row]
        cell.tipTextLabel.text = tip.description
        
        if tip.userName != nil {
            cell.tipUserLabel.text = tip.userName
        }

        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

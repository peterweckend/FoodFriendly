//
//  SideMenuTableViewController.swift
//  The options page accessed from the right hand side

import UIKit
import Firebase

class SideMenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.sectionIdentifiers.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.optionsStrings[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SideMenuTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SideMenuTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SideMenuTableViewCell.")
        }

        // Configure the cell
        cell.sideMenuNameLabel.text = Constants.optionsStrings[indexPath.section][indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.sectionIdentifiers[section]
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "unwindToIntroWithSegue" {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Constants.optionsSegueIdentifiers[indexPath.section][indexPath.row] == "unwindToIntroWithSegue" {
            let introController = self.storyboard?.instantiateViewController(withIdentifier: "introPage")
            self.present(introController!, animated:true, completion:nil)
        }
        
        self.performSegue(withIdentifier: Constants.optionsSegueIdentifiers[indexPath.section][indexPath.row], sender: self)

    }

}

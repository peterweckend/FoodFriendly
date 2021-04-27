//
//  ResetPasswordViewController.swift
//  Edible

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var resetPasswordErrorField: UILabel!
    @IBOutlet weak var resetPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resetPasswordTextField.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ResetPasswordViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // do something with the text entered into the text field
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
    }
    
    // MARK: - Actions
    @IBAction func resetPasswordButtonPressed(_ sender: UIButton) {
        if let resetPasswordEmail = resetPasswordTextField.text {
            Auth.auth().sendPasswordReset(withEmail: resetPasswordEmail) { error in
                if let error = error {
                    //self.invalidMessageTextField.text = "There was a problem creating your account."
                    self.resetPasswordErrorField.text = error.localizedDescription
                    return
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            self.resetPasswordErrorField.text = "Email Address Required."
            return
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

}

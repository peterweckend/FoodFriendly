//
//  SignUpViewController.swift

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {


    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var invalidMessageTextField: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var userId: String?
    var selectedDiet: DietModel?
    var isGlutenFree: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text fields' user input through delegate callbacks.
        emailTextField.delegate = self
        passwordTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self

        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap to not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
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
        
        if segue.identifier == "signUpToProfilePicSegue" {
            guard let uploadProfilePhotoViewController = segue.destination as? UploadProfilePhotoViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            uploadProfilePhotoViewController.firstName = firstNameTextField.text!
            uploadProfilePhotoViewController.lastName = lastNameTextField.text!
            uploadProfilePhotoViewController.isGlutenFree = isGlutenFree!
            uploadProfilePhotoViewController.selectedDiet = selectedDiet!
            if userId != nil {
                uploadProfilePhotoViewController.uid = userId!
            } else {
                print("An error occurred")
            }
        }
        
    }
    
    
    // MARK: - Actions
    @IBAction func createAccountAction(_ sender: UIButton) {
        invalidMessageTextField.text = ""
        
        if firstNameTextField.text == nil || firstNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            invalidMessageTextField.text = "First Name cannot be empty."
            return
        }
        if lastNameTextField.text == nil || lastNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            invalidMessageTextField.text = "Last Name cannot be empty."
            return
        }
        
        Globals.isInSignUp = true
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if let error = error {
                self.invalidMessageTextField.text = error.localizedDescription
                return
            } else {
                guard let uid = user?.user.uid else {
                    return
                }
                self.userId = uid
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                }

                self.performSegue(withIdentifier: "signUpToProfilePicSegue", sender: self)
            }
        }
    }
    
    private func registerUser() {
        
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

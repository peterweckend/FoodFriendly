//
//  UploadProfilePhotoViewController.swift
//  Edible

import UIKit
import Firebase

class UploadProfilePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var uid: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var selectedDiet: DietModel?
    var isGlutenFree = true
    var profilePictureChanged = false // won't be totally accurate, but will save the majority of changes
    var profilePictureNames = ["ProfilePicture1", "ProfilePicture2", "ProfilePicture3", "ProfilePicture4", "ProfilePicture5"]
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePictureImageView.image = UIImage(named: profilePictureNames[Int(arc4random() % 4)])
        
        let storageRef = Storage.storage().reference().child("users/\(uid)/profilePicture.jpg")
        
        // create the user with the default profile picture right away
        if let uploadData = UIImagePNGRepresentation(self.profilePictureImageView.image!) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print(error)
                    } else {
                        if url != nil {
                            let profilePictureUrl = url!.absoluteString
                            // update the user profile
                            print(self.uid)
                            let userProfileRef = Database.database().reference(withPath: "userProfiles/\(self.uid)")
                            let userProfile = UserProfileModel(firstName: self.firstName, lastName: self.lastName, photoUrl: profilePictureUrl, dietName: self.selectedDiet!.name, isGlutenFree: self.isGlutenFree)
                            userProfileRef.setValue(userProfile?.toAnyObject())
                        }
                    }
                    
                }
            })
        }
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profilePictureImageView.image = selectedImage
        }
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadPhotoButtonSelected(_ sender: UIButton) {

        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonSelected(_ sender: UIButton) {
        let storageRef = Storage.storage().reference().child("users/\(uid)/profilePicture.jpg")
        if let uploadData = UIImagePNGRepresentation(self.profilePictureImageView.image!) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print(error)
                    } else {
                        if url != nil {
                            let profilePictureUrl = url!.absoluteString
                            // update the user profile
                            let userProfileRef = Database.database().reference(withPath: "userProfiles/\(self.uid)")
                            let userProfile = UserProfileModel(firstName: self.firstName, lastName: self.lastName, photoUrl: profilePictureUrl, dietName: self.selectedDiet!.name, isGlutenFree: self.isGlutenFree)
                            userProfileRef.setValue(userProfile?.toAnyObject())
                        }
                    }
                        
                }
            })
        self.performSegue(withIdentifier: "uploadProfilePicToHomeSegue", sender: self)
        Globals.isInSignUp = false
        }
    }

}

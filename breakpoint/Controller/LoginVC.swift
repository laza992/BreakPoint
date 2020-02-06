//
//  LoginVC.swift
//  breakpoint
//
//  Created by developer on 15.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class LoginVC: UIViewController {

    // Outlets

    @IBOutlet weak var emailField: InsetTextField!
    @IBOutlet weak var passwordField: InsetTextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tapToChangeProfileImage: UIButton!
    
    var imagePicker: UIImagePickerController!
    
    //guard let image = profileImage.image else { return }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(imageTap)
        profileImage.layer.cornerRadius = profileImage.bounds.height / 2
        profileImage.clipsToBounds = true

        tapToChangeProfileImage.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    
    @objc func openImagePicker(_ sender: Any) {
        // Open image picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func saveImage(image: UIImage, uid: String, completion: @escaping(Error?) -> Void) {
        DataService.instance.uploadProfilePhoto(uid: uid, image: image, completionHandler: completion)
    }
    
    private func authenticationCompletion() {
        let initialTabVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
        let window = UIApplication.shared.windows.first!
        window.makeKeyAndVisible()
        window.rootViewController = initialTabVC
    }
    
    // MARK: - Authentication
    
    private func loginAPI(email: String, password: String) {
        AuthService.instance.loginUser(withEmail: email, andPassword: password) { (success, loginError) in
            if success {
                self.dismiss(animated: true, completion: nil)
                self.authenticationCompletion()
                return
            } else {
                print(String(describing: loginError?.localizedDescription))
                self.signUpAPI(email: email, password: password)
            }
        }
    }
    
    private func signUpAPI(email: String, password: String) {
        AuthService.instance.registerUser(withEmail: email, andPassword: password, image: profileImage.image!) { (error) in
            if error == nil {
                    self.dismiss(animated: true, completion: nil)
                    self.authenticationCompletion()
                
            } else {
                
                print(error?.localizedDescription ?? "Error has occured!")
            }
        }
    }
    
    
    @IBAction func signUpBtnWasPressed(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        loginAPI(email: email, password: password)
    }
    
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension LoginVC: UITextFieldDelegate {
}

extension LoginVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImage.image = pickedImage
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

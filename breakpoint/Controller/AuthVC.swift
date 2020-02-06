//
//  AuthVC.swift
//  breakpoint
//
//  Created by developer on 15.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import Firebase

class AuthVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            dismiss(animated: true, completion: nil)
        }
        super.viewDidAppear(animated)
    }
    
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        
        debugPrint("pressed email")
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        present(loginVC!, animated: true, completion: nil)
    }
    
    @IBAction func facebookSignInBtnWasPressed(_ sender: Any) {
       debugPrint("pressed facebook")
    }
    
    @IBAction func googleSignUpBtnWasPressed(_ sender: Any) {
        debugPrint("pressed google")
    }
    
}

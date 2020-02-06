//
//  AuthService.swift
//  breakpoint
//
//  Created by developer on 15.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import Foundation
import Firebase

class AuthService {
    static let instance = AuthService()
    
    func registerUser(withEmail email: String, andPassword password: String, image: UIImage, userCreationComplete: @escaping (Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard let user = authResult?.user else {
                userCreationComplete(error)
                return
            }
            
            let userData = ["provider": user.providerID, "email": user.email]
            DataService.instance.CreateDBUser(uid: user.uid, userData: userData)
            DataService.instance.uploadProfilePhoto(uid: user.uid, image: image) { (error) in
                userCreationComplete(error)
            }
        }
    }
    
    func loginUser(withEmail email: String, andPassword password: String, loginComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                loginComplete(false, error)
                return
            }
            loginComplete(true, nil)
        }
    }
}

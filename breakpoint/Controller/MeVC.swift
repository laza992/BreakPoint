//
//  MeVC.swift
//  breakpoint
//
//  Created by developer on 16.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import Firebase

class MeVC: UIViewController {

    // Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneBtn: UIButton!
    
    var messageArray = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        getUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailLbl.text = Auth.auth().currentUser?.email
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataService.instance.getAllFeedMessages { (returnedMessagesArray)in
            self.messageArray = returnedMessagesArray.reversed()
            self.messageArray = self.messageArray.filter({$0.senderId == Auth.auth().currentUser?.uid})
            self.tableView.reloadData()
        }
    }
    
    private func setupUI() {
        doneBtn.isHidden = true
        textView.delegate = self
        tableView.separatorColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func getUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DataService.instance.getDescription(forUID: uid) { [weak self] (description) in
            guard let self = self else { return }
            
            self.textView.text = description
        }
    }
    
    @IBAction func doneBtnWasPressed(_ sender: Any) {
        if textView != nil && textView.text != "Write something about you!" {
            DataService.instance.updateProfile(withBio: textView.text, forUID: (Auth.auth().currentUser?.uid)!) { (isUpdated) in
                if isUpdated {
                    self.dismiss(animated: true, completion: nil)
                    self.getUserInfo()
                } else {
                    print("There was an error!")
                }
            }
        }
    }
    
    @IBAction func signOutBtnWasPressed(_ sender: Any) {
        let logoutPopup = UIAlertController(title: "logout?", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Logout?", style: .destructive) { (buttonTapped) in
            do {
                try Auth.auth().signOut()
                let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
                self.present(authVC!, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
        
        logoutPopup.addAction(cancelAction)
        logoutPopup.addAction(logoutAction)
        present(logoutPopup, animated: true, completion: nil)
    }
}

extension MeVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "myFeedsCell") as? MyFeedsCell else {
            return UITableViewCell()
        }
        let image = UIImage(named: "defaultProfileImage")
        let message = messageArray[indexPath.row]
        
        DataService.instance.getUsername(forUID: message.senderId) { (returnedUsername) in
            cell.configureCell(profileImage: image!, email: returnedUsername, content: message.content)
        }
    return cell
    }
}
extension MeVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        doneBtn.isHidden = false
        textView.text = ""
    }
}

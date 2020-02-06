//
//  DataService.swift
//  breakpoint
//
//  Created by developer on 15.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = Database.database().reference()

class DataService {
    static let instance = DataService()
    static let storageRef = Storage.storage().reference()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_GROUPS = DB_BASE.child("groups")
    private var _REF_FEED = DB_BASE.child("feed")
    
    var uid: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_GROUPS: DatabaseReference {
        return _REF_GROUPS
    }
    
    var REF_FEED: DatabaseReference {
        return _REF_FEED
    }
    
    func CreateDBUser(uid: String, userData: [String: Any]) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func updateProfile(withBio bio: String, forUID uid: String, updateCompleted: @escaping (_ status: Bool) -> ()) {
        
        REF_USERS.child(uid).updateChildValues(["bio": bio, "uid": uid])
        updateCompleted(true)
    }
    
    func uploadPost(withMessage message: String, forUID uid: String, withGroupKey groupkey: String?, sendComplete: @escaping (_ status: Bool) -> ()) {
        if groupkey != nil {
            REF_GROUPS.child(groupkey!).child("messages").childByAutoId().updateChildValues(["content": message, "senderId": uid])
            sendComplete(true)
        } else {
            REF_FEED.childByAutoId().updateChildValues(["content": message, "senderId": uid])
            sendComplete(true)
        }
    }
    
    func getUsername(forUID uid: String, handler: @escaping(_ username: String) -> ()){
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for user in userSnapshot {
                if user.key == uid {
                    handler(user.childSnapshot(forPath: "email").value as! String)
                }
            }
        }
    }
    
    func uploadProfilePhoto(uid: String, image: UIImage, completionHandler: @escaping (Error?) -> ()) {
        
        let userStorageRef = DataService.storageRef.child("user\(uid)")
        let metaData = StorageMetadata()
        metaData.contentType = "img/jpg"
        
        if let data = image.jpegData(compressionQuality: 0.9) {
            userStorageRef.putData(data, metadata: metaData) { (_, error)
                in
                if let error = error {
                    completionHandler(error)
                } else {
                    userStorageRef.downloadURL { (url, error) in
                        if let url = url {
                            // Save URL to user database

                        DataService.instance.REF_USERS.child(uid).updateChildValues(["profileImage": url.absoluteString], withCompletionBlock: { (error, _)
                            in
                            completionHandler(error)
                            })
                        } else {
                            completionHandler(error)
                        }
                    }
                }
            }
        }
    }
    
    func getDescription(forUID uid: String, handler: @escaping(_ description: String?) -> ()){
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for user in userSnapshot {
                if user.key == uid {
                    handler(user.childSnapshot(forPath: "bio").value as? String)
                }
            }
        }
    }
    
    func getAllFeedMessages(handler: @escaping (_ messages: [Message]) -> ()) {
        var messageArray = [Message]()
        REF_FEED.observeSingleEvent(of: .value) { (feedMessageSnapshot) in
            guard let feedMessageSnapshot = feedMessageSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for message in feedMessageSnapshot {
                let content = message.childSnapshot(forPath: "content").value as! String
                let senderId = message.childSnapshot(forPath: "senderId").value as! String
                let message = Message(content: content, senderId: senderId)
                
                messageArray.append(message)
            }
            
            handler(messageArray)
        }
    }
    
    func getAllMessagesFor(desiredGroup: Group, handler: @escaping (_ messagesArray: [Message]) -> ()) {
        var groupMessageArray = [Message]()
        REF_GROUPS.child(desiredGroup.key).child("messages").observeSingleEvent(of: .value) { (groupMessageSnapshot) in
            guard let groupMessageSnapshot = groupMessageSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for groupMessage in groupMessageSnapshot {
                let content = groupMessage.childSnapshot(forPath: "content").value as! String
                let senderId = groupMessage.childSnapshot(forPath: "senderId").value as! String
                let groupMessage = Message(content: content, senderId: senderId)
                groupMessageArray.append(groupMessage)
            }
            handler(groupMessageArray)
        }
    }
    
    func getEmail(forSearchQuery query: String, handler: @escaping (_ emailArray: [String]) -> ()) {
        var emailArray = [String]()
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnaphot = userSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for user in userSnaphot {
                let email = user.childSnapshot(forPath: "email").value as! String
                
                if email.contains(query) == true && email != Auth.auth().currentUser?.email {
                    emailArray.append(email)
                }
            }
            handler(emailArray)
        }
    }
    
    func getIds(forUsernames usernames: [String], handler: @escaping (_ uidArray: [String]) -> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            var idArray = [String]()
            guard let userSnaphot = userSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for user in userSnaphot {
                let email = user.childSnapshot(forPath: "email").value as! String
                
                if usernames.contains(email) {
                    idArray.append(user.key)
                }
            }
            handler(idArray)
        }
    }
    
    func getEmailsFor(group: Group, handler: @escaping (_ emailArray: [String]) -> ()){
        var emailArray = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for user in userSnapshot {
                if group.members.contains(user.key) {
                    let email = user.childSnapshot(forPath: "email").value as! String
                    emailArray.append(email)
                }
            }
            handler(emailArray)
        }
    }
    
    func createGroup(withTitle title: String, andDescription description: String, forUserIds ids: [String], handler: @escaping (_ groupCreated: Bool) -> ()) {
        REF_GROUPS.childByAutoId().updateChildValues(["title" : title, "description": description, "members": ids])
        handler(true)
    }
    
    func getAllGroups(handler: @escaping (_ groupsArray: [Group]) -> ()) {
        var groupsArray = [Group]()
        REF_GROUPS.observeSingleEvent(of: .value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for group in groupSnapshot {
                let memberArray = group.childSnapshot(forPath: "members").value as! [String]
                if memberArray.contains((Auth.auth().currentUser?.uid)!) {
                    let title = group.childSnapshot(forPath: "title").value as! String
                    let descripion = group.childSnapshot(forPath: "description").value as! String
                    let group = Group(title: title, description: descripion, key: group.key, members: memberArray, memberCount: memberArray.count)
                    groupsArray.append(group)
                }
            }
            handler(groupsArray)
        }
    }
    
}


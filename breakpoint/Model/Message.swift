//
//  Message.swift
//  breakpoint
//
//  Created by developer on 16.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import Foundation

class Message {
    var content: String
    var senderId: String
    
    init(content: String, senderId: String) {
        self.content = content
        self.senderId = senderId
    }
}

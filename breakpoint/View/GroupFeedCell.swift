//
//  GroupFeedCell.swift
//  breakpoint
//
//  Created by developer on 17.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit

class GroupFeedCell: UITableViewCell {

   // Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var contentlbl: UILabel!
    
    func configureCell(profileImage: UIImage, email: String, content: String) {
        self.profileImage.image = profileImage
        self.emailLbl.text = email
        self.contentlbl.text = content
    }
    
}

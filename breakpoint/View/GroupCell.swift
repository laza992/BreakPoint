//
//  GroupCell.swift
//  breakpoint
//
//  Created by developer on 17.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var groupTitleLbl: UILabel!
    @IBOutlet weak var groupDescriptionLbl: UILabel!
    @IBOutlet weak var memberCountLbl: UILabel!
    
    func configureCell(title: String, description: String, memberCount: Int) {
        self.groupTitleLbl.text = title
        self.groupDescriptionLbl.text = description
        self.memberCountLbl.text = "\(memberCount) members."
    }
}

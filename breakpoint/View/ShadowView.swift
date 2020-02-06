//
//  ShadowView.swift
//  breakpoint
//
//  Created by developer on 15.10.19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    override func awakeFromNib() {
        SetupView()
        super.awakeFromNib()
    }

    func SetupView() {
        self.layer.shadowOpacity = 0.75
        self.layer.shadowRadius = 5
        self.layer.shadowColor = #colorLiteral(red: 0.1194795221, green: 0.1194795221, blue: 0.1194795221, alpha: 1)
    }

}

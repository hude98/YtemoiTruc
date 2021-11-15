//
//  RoundButton.swift
//  ytemoi_app_yta
//
//  Created by Ta Huy Hung on 31/03/2021.
//

import UIKit

@IBDesignable class RoundTextView : UITextView {
    @IBInspectable var cornerRadius : CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var borderColor : UIColor = UIColor.white{
        didSet{
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = 1
        }
    }
}

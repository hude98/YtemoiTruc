//
//  CustomUIVisualEffectView.swift
//  ytemoi_app_yta
//
//  Created by Ta Huy Hung on 04/09/2021.
//

import UIKit

@IBDesignable class RoundUIVisualEffectView: UIVisualEffectView {
    @IBInspectable var cornerRadius : CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
}

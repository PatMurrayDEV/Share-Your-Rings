//
//  RoundedButton.swift
//  CloseTheRings
//
//  Created by Patrick Murray on 10/5/18.
//  Copyright © 2018 Patrick Murray. All rights reserved.
//

import UIKit
import AVFoundation

@IBDesignable
class RoundedButton: UIButton {

    override func awakeFromNib() {
        let roundedPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.bounds.height/2)
        let maskLayer = CAShapeLayer()
        maskLayer.path = roundedPath.cgPath
        layer.mask = maskLayer
        self.backgroundColor = UIColor(red:0.78, green:0.36, blue:0.16, alpha:1.00)
    }
    


}

@IBDesignable
class RotatedLabel: UILabel {
    
    override func awakeFromNib() {
        let spareFrame = self.frame
        self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        self.frame = spareFrame
    }
    
    
    
}



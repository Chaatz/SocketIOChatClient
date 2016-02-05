//
//  GradientView.swift
//  Pods
//
//  Created by Kenneth on 5/2/2016.
//
//

import UIKit

class GradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    convenience init(colors: [AnyObject], locations: [NSNumber]) {
        self.init()
        backgroundColor = UIColor.clearColor()
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
//
//  GradientBackgroundView.swift
//  Minechecker
//
//  Created by Ryan Donaldson on 7/30/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//
 
import UIKit

class GradientBackgroundView: UIView {
    
    override func draw(_ rect: CGRect) {
        // Color Constants
        let lightOrange: UIColor = UIColor(rgba: "#F9845B")
        let darkOrange: UIColor = UIColor(rgba: "#FA602A")
        
        // Setup Context
        let context = UIGraphicsGetCurrentContext()
        
        // Gradient Constant
        let gradientFromColors = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [lightOrange.cgColor, darkOrange.cgColor] as CFArray, locations: [0, 1])
        
        // Gradient Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        context?.saveGState()
        backgroundPath.addClip()
        context?.drawLinearGradient(gradientFromColors!, start: CGPoint(x: 160, y: 0), end: CGPoint(x: 160, y: 568), options: CGGradientDrawingOptions.drawsAfterEndLocation)
        context?.restoreGState()
    }
    
}

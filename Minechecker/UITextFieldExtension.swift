//
//  UITextFieldExtension.swift
//  Minechecker
//
//  Created by Ryan Donaldson on 7/24/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import UIKit

extension UITextField {
    func setTextLeftPadding(_ left: CGFloat) {
        let leftView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: 1))
        leftView.backgroundColor = UIColor.clear
        self.leftView = leftView;
        self.leftViewMode = UITextFieldViewMode.always;
    }
}

//
//  UIViewController.swift
//  Developex Test
//
//  Created by Dima Medynsky on 4/25/16.
//  Copyright © 2016 Dima Medynsky. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
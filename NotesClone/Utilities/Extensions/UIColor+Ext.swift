//
//  UIColor+Ext.swift
//  NotesClone
//
//  Created by Selin Kayar on 16.07.24.
//

import UIKit

extension UIColor {
    func darker(by percentage: CGFloat) -> UIColor? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: max(r - percentage / 100.0, 0.0),
                           green: max(g - percentage / 100.0, 0.0),
                           blue: max(b - percentage / 100.0, 0.0),
                           alpha: a)
        }
        return nil
    }
}

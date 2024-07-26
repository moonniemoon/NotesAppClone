//
//  UIView+Ext.swift
//  NotesClone
//
//  Created by Selin Kayar on 7.07.24.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach({
            addSubview($0)
        })
    }
}

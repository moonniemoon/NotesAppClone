//
//  UIFont.swift
//  NotesClone
//
//  Created by Selin Kayar on 20.07.24.
//

import UIKit

extension UIFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }

    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
}

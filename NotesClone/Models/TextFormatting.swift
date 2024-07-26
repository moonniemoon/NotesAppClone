//
//  TextFormatting.swift
//  NotesClone
//
//  Created by Selin Kayar on 17.07.24.
//

import Foundation

struct TextFormatting: Equatable {
    var size: CGFloat
    var isBold: Bool
    var isItalic: Bool
    var isUnderlined: Bool
    
    static func == (lhs: TextFormatting, rhs: TextFormatting) -> Bool {
        return lhs.size == rhs.size && lhs.isBold == rhs.isBold && lhs.isItalic == rhs.isItalic && lhs.isUnderlined == rhs.isUnderlined
    }
}

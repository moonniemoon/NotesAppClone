//
//  indexPathFromIdentifier.swift
//  NotesClone
//
//  Created by Selin Kayar on 12.07.24.
//

import Foundation

struct IndexPathUtils {
    static func indexPathFromIdentifier(_ identifier: String) -> IndexPath? {
        let components = identifier.components(separatedBy: "-")
        guard components.count == 2,
              let section = Int(components[0]),
              let row = Int(components[1]) else {
            return nil
        }
        return IndexPath(row: row, section: section)
    }
}

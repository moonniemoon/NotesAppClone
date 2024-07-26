//
//  Date+Ext.swift
//  NotesClone
//
//  Created by Selin Kayar on 7.07.24.
//

import Foundation

extension Date {
    func dateFormatter() -> String {
        let dateFormatter = DateFormatter()
        if Calendar.current.isDateInToday(self) {
            dateFormatter.dateFormat = "h:mm a"
        } else {
            dateFormatter.dateFormat = "dd.MM.yy"
        }
        return dateFormatter.string(from: self)
    }
}

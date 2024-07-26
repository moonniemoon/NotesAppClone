//
//  Note+CoreDataClass.swift
//  NotesClone
//
//  Created by Selin Kayar on 25.07.24.
//
//

import Foundation
import CoreData


public class Note: NSManagedObject {
    var attributedText: NSAttributedString? {
        get {
            guard let data = textData else { return nil }
            
            do {
                return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: data)
            } catch {
                print("Failed to unarchive NSAttributedString: \(error)")
                return try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtfd], documentAttributes: nil)
            }
        }
        set {
            do {
                textData = try NSKeyedArchiver.archivedData(withRootObject: newValue ?? NSAttributedString(string: ""), requiringSecureCoding: false)
            } catch {
                print("Failed to archive NSAttributedString: \(error)")
            }
        }
    }
    
    var title: String {
        let text = searchableText ?? ""
        let lines = text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
        
        return lines.first(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) ?? "New Note"
    }
    
    var additionalText: String {
        let text = searchableText ?? ""
        var lines = text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
        
        if !lines.isEmpty {
            lines.removeFirst()
        }
        
        return findFirstNonEmptyLine(from: lines)
    }
    
    private func findFirstNonEmptyLine(from lines: [String]) -> String {
        for line in lines {
            if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                return line
            }
        }
        return "No Additional Text"
    }
}

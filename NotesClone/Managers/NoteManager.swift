//
//  NoteManager.swift
//  NotesClone
//
//  Created by Selin Kayar on 7.07.24.
//

import Foundation
import CoreData

protocol NoteManagerProtocol {
    func createNote() -> Note
    func delete(note: Note)
    func setNotePinned(_ note: Note, pinned: Bool)
    func updateNoteText(_ note: Note, attributedText: NSAttributedString)
    func createNotesFetchedResultsController(filter: String?, isPinned: Bool, groupedByDate: Bool) -> NSFetchedResultsController<Note>
}

final class NoteManager: NoteManagerProtocol {
    
    static let shared = NoteManager()
    private let coreDataManager: CoreDataManager
    
    private init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    func createNote() -> Note {
        let note = Note(context: coreDataManager.viewContext)
        note.id = UUID()
        note.attributedText = NSAttributedString(string: "")
        note.searchableText = ""
        note.lastUpdated = Date()
        note.isPinned = false
        coreDataManager.saveContext()
        return note
    }
    
    func delete(note: Note) {
        coreDataManager.viewContext.delete(note)
        coreDataManager.saveContext()
    }
    
    func setNotePinned(_ note: Note, pinned: Bool) {
        note.isPinned = pinned        
        coreDataManager.saveContext()
    }
    
    func updateNoteText(_ note: Note, attributedText: NSAttributedString) {
        note.attributedText = attributedText
        note.searchableText = attributedText.string
        note.lastUpdated = Date()
        coreDataManager.saveContext()
    }
    
    func createNotesFetchedResultsController(filter: String? = nil, isPinned: Bool, groupedByDate: Bool = false) -> NSFetchedResultsController<Note> {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.lastUpdated, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        var predicates: [NSPredicate] = [NSPredicate(format: "isPinned == %@", NSNumber(value: isPinned))]
        if let filter = filter {
            predicates.append(NSPredicate(format: "searchableText contains[cd] %@", filter))
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let sectionNameKeyPath: String? = groupedByDate ? "sectionIdentifier" : nil
        
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: coreDataManager.viewContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
    }
}

extension Note {
    @objc var sectionIdentifier: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(lastUpdated!) {
            return "Today"
        } else if calendar.isDateInYesterday(lastUpdated!) {
            return "Yesterday"
        } else {
            let components = calendar.dateComponents([.year, .month, .day], from: lastUpdated!)
            let date = calendar.date(from: components)!
            let now = Date()
            
            if now.timeIntervalSince(date) < 7 * 24 * 60 * 60 {
                return "Previous 7 Days"
            } else if now.timeIntervalSince(date) < 30 * 24 * 60 * 60 {
                return "Previous 30 days"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM yyyy"
                return formatter.string(from: lastUpdated!)
            }
        }
    }
}

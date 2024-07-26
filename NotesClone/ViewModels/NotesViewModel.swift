//
//  NotesViewModel.swift
//  NotesClone
//
//  Created by Selin Kayar on 8.07.24.
//

import Foundation
import CoreData

final class NotesViewModel: NSObject, NSFetchedResultsControllerDelegate {
    
    private let noteManager: NoteManagerProtocol
    private let userDefaults = UserDefaults.standard
    private var pinnedFetchedResultsController: NSFetchedResultsController<Note>!
    private var regularFetchedResultsController: NSFetchedResultsController<Note>!
    
    var didChangeContent: (() -> Void)?
    
    var isPinnedSectionCollapsed: Bool {
        get {
            return userDefaults.bool(forKey: "isPinnedSectionCollapsed")
        }
        set {
            userDefaults.set(newValue, forKey: "isPinnedSectionCollapsed")
            userDefaults.synchronize()
        }
    }
    
    init(noteManager: NoteManagerProtocol = NoteManager.shared) {
        self.noteManager = noteManager
        if userDefaults.object(forKey: "isPinnedSectionCollapsed") == nil {
            userDefaults.set(false, forKey: "isPinnedSectionCollapsed")
        }
        super.init()
        setupFetchedResultsControllers()
        fetchNotes()
    }
    
    private func setupFetchedResultsControllers(filter: String? = nil) {
        pinnedFetchedResultsController = noteManager.createNotesFetchedResultsController(filter: filter, isPinned: true, groupedByDate: false)
        pinnedFetchedResultsController.delegate = self
        
        regularFetchedResultsController = noteManager.createNotesFetchedResultsController(filter: filter, isPinned: false, groupedByDate: true)
        regularFetchedResultsController.delegate = self
    }
    
    func fetchNotes() {
        do {
            try pinnedFetchedResultsController.performFetch()
            try regularFetchedResultsController.performFetch()
            didChangeContent?()
        } catch {
            print("Failed to fetch notes: \(error.localizedDescription)")
        }
    }
    
    func createNote() -> Note {
        let note = noteManager.createNote()
        didChangeContent?()
        return note
    }
    
    func deleteNote(_ note: Note) {
        noteManager.delete(note: note)
        didChangeContent?()
    }
    
    func setNotePinned(_ note: Note, pinned: Bool) {
        noteManager.setNotePinned(note, pinned: pinned)
        didChangeContent?()
    }
    
    func numberOfSections() -> Int {
        return 1 + (regularFetchedResultsController.sections?.count ?? 0)
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        if section == 0 {
            return isPinnedSectionCollapsed ? 0 : (pinnedFetchedResultsController.sections?.first?.numberOfObjects ?? 0)
        } else {
            return regularFetchedResultsController.sections?[section - 1].numberOfObjects ?? 0
        }
    }
    
    func noteAt(indexPath: IndexPath) -> Note {
        if indexPath.section == 0 {
            return pinnedFetchedResultsController.object(at: IndexPath(row: indexPath.row, section: 0))
        } else {
            return regularFetchedResultsController.object(at: IndexPath(row: indexPath.row, section: indexPath.section - 1))  // check - 1
        }
    }
    
    func filterNotes(with query: String) {
        setupFetchedResultsControllers(filter: query.isEmpty ? nil : query)
        fetchNotes()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        didChangeContent?()
    }
    
    func totalPinnedNotesCount() -> Int {
        return pinnedFetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }
    
    func totalRegularNotesCount() -> Int {
        return regularFetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func regularNotesSectionTitle(section: Int) -> String {
        return regularFetchedResultsController.sections?[section - 1].name ?? "Section Name"
    }
    
    func togglePinnedSection() {
        isPinnedSectionCollapsed.toggle()
        didChangeContent?()
    }
}

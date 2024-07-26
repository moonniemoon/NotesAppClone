//
//  NotesTableViewDataSource.swift
//  NotesClone
//
//  Created by Selin Kayar on 9.07.24.
//

import UIKit
import CoreData

class NotesTableViewDataSource: NSObject {
    private let notesViewModel: NotesViewModel
    private weak var tableView: UITableView?

    init(viewModel: NotesViewModel, tableView: UITableView) {
        self.notesViewModel = viewModel
        self.tableView = tableView
        self.tableView?.register(NoteDetailsTableViewCell.self, forCellReuseIdentifier: NoteDetailsTableViewCell.reuseID)
        super.init()
        self.tableView?.dataSource = self
    }
}

extension NotesTableViewDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return notesViewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 && notesViewModel.isPinnedSectionCollapsed ? 0 : notesViewModel.numberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteDetailsTableViewCell.reuseID, for: indexPath) as? NoteDetailsTableViewCell else {
            return UITableViewCell()
        }
        let note = notesViewModel.noteAt(indexPath: indexPath)
        cell.configure(with: note)
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = notesViewModel.noteAt(indexPath: indexPath)
            notesViewModel.deleteNote(note)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

extension NotesTableViewDataSource: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView?.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView?.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView?.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            tableView?.reloadRows(at: [indexPath!], with: .automatic)
        @unknown default:
            tableView?.reloadData()
        }
    }
}

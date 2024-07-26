//
//  NotesTableViewDelegate.swift
//  NotesClone
//
//  Created by Selin Kayar on 9.07.24.
//

import UIKit

protocol NoteSelectionDelegate: AnyObject {
    func didSelect(note: Note)
}

class NotesTableViewDelegate: NSObject {
    weak var selectionDelegate: NoteSelectionDelegate?

    private let notesViewModel: NotesViewModel
    private weak var tableView: UITableView?

    init(viewModel: NotesViewModel, tableView: UITableView) {
        self.notesViewModel = viewModel
        self.tableView = tableView
        self.tableView?.register(CollapsibleTableViewHeader.self, forHeaderFooterViewReuseIdentifier: CollapsibleTableViewHeader.reuseID)
        super.init()
        self.tableView?.delegate = self
    }
}


extension NotesTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notesViewModel.noteAt(indexPath: indexPath)
        selectionDelegate?.didSelect(note: note)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return createTrailingSwipeActionsConfiguration(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return createLeadingSwipeActionsConfiguration(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 && notesViewModel.isPinnedSectionCollapsed ? 0 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderView(for: section)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let note = notesViewModel.noteAt(indexPath: indexPath)
        let identifier = "\(indexPath.section)-\(indexPath.row)" as NSString
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
            return self.previewViewController(for: note)
        }) { [weak self] _ in
            self?.makeContextMenu(note: note)
        }
    }
    
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? String,
              let indexPath = IndexPathUtils.indexPathFromIdentifier(identifier),
              let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }
        return UITargetedPreview(view: cell)
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
        guard let identifierString = configuration.identifier as? String,
              let indexPath = IndexPathUtils.indexPathFromIdentifier(identifierString) else {
            return
        }
        let note = notesViewModel.noteAt(indexPath: indexPath)
        selectionDelegate?.didSelect(note: note)
    }
}

private extension NotesTableViewDelegate {
    private func createTrailingSwipeActionsConfiguration(for indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return
            }
            let note = self.notesViewModel.noteAt(indexPath: indexPath)
            self.notesViewModel.deleteNote(note)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let folderItAction = UIContextualAction(style: .normal, title: "Folder It") { (action, view, completionHandler) in
            // folder it action
            completionHandler(true)
        }
        folderItAction.image = UIImage(systemName: "folder.fill")
        folderItAction.backgroundColor = .systemIndigo
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (action, view, completionHandler) in
            // share action
            completionHandler(true)
        }
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        shareAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, folderItAction, shareAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    private func createLeadingSwipeActionsConfiguration(for indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let section = indexPath.section
        let pinAction = UIContextualAction(style: .normal, title: section == 0 ? "Unpin" : "Pin") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let note = self.notesViewModel.noteAt(indexPath: indexPath)
            self.notesViewModel.setNotePinned(note, pinned: section == 0 ? false : true)
            completionHandler(true)
        }
        pinAction.image = UIImage(systemName: section == 0 ? "pin.slash.fill" : "pin.fill")
        pinAction.backgroundColor = .systemOrange
        
        let configuration = UISwipeActionsConfiguration(actions: [pinAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    private func createHeaderView(for section: Int) -> UIView? {
        if section == 0 {
            guard let header = tableView?.dequeueReusableHeaderFooterView(withIdentifier: CollapsibleTableViewHeader.reuseID) as? CollapsibleTableViewHeader else { return UIView() }
            header.titleLabel.text = "Pinned"
            header.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
            header.delegate = self
            header.setCollapsed(notesViewModel.isPinnedSectionCollapsed)
            return header
        } else {
            let headerLabel = UILabel()
            headerLabel.text = notesViewModel.regularNotesSectionTitle(section: section)
            headerLabel.textAlignment = .left
            headerLabel.font = UIFont.boldSystemFont(ofSize: 17)
            headerLabel.textColor = .label
            return headerLabel
        }
    }
    
    private func makeContextMenu(note: Note) -> UIMenu {
        let pinValue = note.isPinned
        let pinAction = UIAction(title: "\(pinValue ? "Unpin" : "Pin") Note", image: UIImage(systemName: "pin")) { [weak self] _ in
            self?.notesViewModel.setNotePinned(note, pinned: !pinValue)
        }
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            self?.notesViewModel.deleteNote(note)
        }
        return UIMenu(title: "", image: nil, children: [pinAction, deleteAction])
    }
    
    private func previewViewController(for note: Note) -> UIViewController? {
        let previewController = UIViewController()
        let textView = FormattedTextView()
        textView.attributedText = note.attributedText
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.frame = previewController.view.bounds.insetBy(dx: 16, dy: 16)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        previewController.view.addSubview(textView)
        return previewController
    }
}


extension NotesTableViewDelegate: CollapsibleTableViewHeaderDelegate {
    func toggleSection(header: CollapsibleTableViewHeader) {
        notesViewModel.isPinnedSectionCollapsed.toggle()
        header.setCollapsed(notesViewModel.isPinnedSectionCollapsed)
        tableView?.reloadSections([0], with: .automatic)
    }
}

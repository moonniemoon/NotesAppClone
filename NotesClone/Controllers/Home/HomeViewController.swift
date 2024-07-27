//
//  HomeViewController.swift
//  NotesClone
//
//  Created by Selin Kayar on 7.07.24.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {

    private let notesViewModel: NotesViewModel
    
    private var notesTableViewDataSource: NotesTableViewDataSource!
    private var notesTableViewDelegate: NotesTableViewDelegate!
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = .init(top: 0, left: 0, bottom: 30, right: 0)
        return tableView
    }()
    
    private let searchController = UISearchController()
    private let blurryFooterView = HomeFooterView()
    
    init(viewModel: NotesViewModel) {
        self.notesViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        configureViewController()
        configureNavigationController()
        configureSearchBar()
        configureTableView()
        configureFooterView()
        
        notesViewModel.didChangeContent = { [weak self] in
            self?.tableView.reloadData()
            self?.updateFooterView()
        }
        notesViewModel.fetchNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.standardAppearance.backgroundColor = nil
        navigationController?.navigationBar.prefersLargeTitles = true
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemGroupedBackground
        title = "Notes"
    }
    
    private func configureNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemYellow.darker(by: 12)
        navigationController?.navigationBar.standardAppearance.shadowColor = nil
        
        let rightNavigationBarItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(barButtonItemPressed(_:)))
        rightNavigationBarItem.tintColor = .systemYellow.darker(by: 12)
        navigationItem.rightBarButtonItem = rightNavigationBarItem
    }
    
    private func configureSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Note"
        searchController.searchBar.tintColor = .systemYellow.darker(by: 12)
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func configureTableView() {
        tableView.frame = view.bounds
        notesTableViewDataSource = NotesTableViewDataSource(viewModel: notesViewModel, tableView: tableView)
        notesTableViewDelegate = NotesTableViewDelegate(viewModel: notesViewModel, tableView: tableView)
        notesTableViewDelegate.selectionDelegate = self
        view.addSubview(tableView)
    }
    
    private func configureFooterView() {
        view.addSubview(blurryFooterView)
        blurryFooterView.delegate = self
        NSLayoutConstraint.activate([
            blurryFooterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            blurryFooterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurryFooterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurryFooterView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func pushNoteDetailsViewController(_ note: Note) {
        let controller = NoteDetailsViewController(note: note)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func barButtonItemPressed(_ sender: UIBarButtonItem) {
        print("rightNavigationBarItem button action not set. Actions that this button has in the real app are:\n- Viewing tableView as Gallery\n- Selecting notes\n- Sorting By (Date Edited, Date Created, Title, ASC and DESC for date edited.\nNOTE: Will probably try to do this later.\n- Group By Date (on/off).\nNOTE: Will probably try to do this later too.\n- View Attachments")
    }

    private func updateFooterView() {
        let pinnedCount = notesViewModel.totalPinnedNotesCount()
        let regularCount = notesViewModel.totalRegularNotesCount()
        blurryFooterView.delegate?.updateNoteCount(pinnedCount + regularCount)
    }
}

extension HomeViewController: HomeFooterDelegate {
    func imageTapped() {
        pushNoteDetailsViewController(notesViewModel.createNote())
    }
    
    func updateNoteCount(_ count: Int) {
        blurryFooterView.notesCountLabel.text = "\(count) \(count == 1 ? "Note" : "Notes")"
    }
}

extension HomeViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        search(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search("")
    }
    
    func search(_ query: String) {
        notesViewModel.filterNotes(with: query)
    }
}

extension HomeViewController: NoteSelectionDelegate {
    func didSelect(note: Note) {
        pushNoteDetailsViewController(note)
    }
}

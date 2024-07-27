//
//  NoteDetailsViewController.swift
//  NotesClone
//
//  Created by Selin Kayar on 8.07.24.
//

import UIKit
import CoreData

class NoteDetailsViewController: UIViewController {
    
    var note: Note!
    private var formattedTextView: FormattedTextView!
    private var firstLineChecked = false
    private var textViewBottomConstraint: NSLayoutConstraint!
    
    init(note: Note) {
        super.init(nibName: nil, bundle: nil)
        self.note = note
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.standardAppearance.backgroundColor = .systemBackground
        
        configureTextView()
        
        if let attributetext = note.attributedText {
            formattedTextView.attributedText = attributetext
        } else {
            formattedTextView.text = ""
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveTextViewData), name: .appWillSaveData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        formattedTextView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        endEditing()
    }
    
    private func configureTextView() {
        formattedTextView = FormattedTextView()
        
        let toolbar = NoteToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44), delegate: self)
        formattedTextView.inputAccessoryView = toolbar
        formattedTextView.delegate = self
        view.addSubview(formattedTextView)
        formattedTextView.translatesAutoresizingMaskIntoConstraints = false
    
        textViewBottomConstraint = formattedTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            formattedTextView.topAnchor.constraint(equalTo: view.topAnchor),
            formattedTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formattedTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textViewBottomConstraint
        ])
    }
    
    private func showHideDoneBarButton() {
        if self.navigationItem.rightBarButtonItem == nil {
            let rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
            rightButton.tintColor = .systemYellow.darker(by: 12)
            self.navigationItem.rightBarButtonItem = rightButton
        } else {
            self.navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    
    private func updateNote() {
        guard let note = note else { return }
        let noteManager = NoteManager.shared
        noteManager.updateNoteText(note, attributedText: formattedTextView.attributedText)
    }
    
    private func deleteNote() {
        NoteManager.shared.delete(note: note)
    }
    
    private func endEditing() {
        guard let note = note else { return }
        
        if formattedTextView.attributedText.length == 0 {
            deleteNote()
        } else {
            note.textData = formattedTextView.attributedTextData()
            updateNote()
        }
    }
    
    @objc private func saveTextViewData() {
        updateNote()
    }
    
    @objc private func doneButtonTapped() {
        formattedTextView.resignFirstResponder()
        showHideDoneBarButton()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            textViewBottomConstraint.constant = -keyboardHeight
            view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        textViewBottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    @objc func presentModalController() {
        let currentAttributes = formattedTextView.getCurrentTextAttributes()
        let vc = FormatModalViewController(textFormatting: currentAttributes)
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .appWillSaveData, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension NoteDetailsViewController: NoteToolbarDelegate {
    func didTapToolbarButton(withTag tag: Int) {
        switch tag {
        case 0:
            presentModalController()
        case 1:
            print("Pressed checklist button")
        case 2:
            print("Pressed table cells button")
        case 3:
            print("Pressed camera button")
        case 4:
            print("Pressed PencilKit button")
        default:
            return
        }
    }
}

extension NoteDetailsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.showHideDoneBarButton()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        endEditing()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            formattedTextView.typingAttributes = [:]
            formattedTextView.revertToDefaultFormatting()
        }
        return true
    }
}

extension NoteDetailsViewController: FormatModalViewControllerDelegate {
    func didUpdateTextFormatting(_ formatting: TextFormatting) {
        if formatting.size == 23 || formatting.size == 18 || formatting.size == 15 { // Fix: Instead of using hardcoded data, create a font size scheme
            formattedTextView.updateFormattingForRange(fontSize: formatting.size, isBold: formatting.isBold, isItalic: formatting.isItalic, isUnderlined: formatting.isUnderlined)
        } else {
            formattedTextView.updateTextAttributes(fontSize: formatting.size, isBold: formatting.isBold, isItalic: formatting.isItalic, isUnderlined: formatting.isUnderlined)
        }
    }
}

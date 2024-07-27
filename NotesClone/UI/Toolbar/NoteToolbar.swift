//
//  NoteToolbar.swift
//  NotesClone
//
//  Created by Selin Kayar on 27.07.24.
//

import UIKit

protocol NoteToolbarDelegate: AnyObject {
    func didTapToolbarButton(withTag tag: Int)
}

class NoteToolbar: UIToolbar {

    weak var noteToolbarDelegate: NoteToolbarDelegate?

    init(frame: CGRect, delegate: NoteToolbarDelegate?) {
        self.noteToolbarDelegate = delegate
        super.init(frame: frame)
        NoteToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: .any)
        setupToolbar()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupToolbar() {
        barStyle = .default
        barTintColor = .systemGray5
        isUserInteractionEnabled = true
        sizeToFit()
        
        let buttons = [
            createBarButtonItem(imageName: "textformat.alt", tag: 0, disabled: false),
            createBarButtonItem(imageName: "checklist", tag: 1, disabled: true),
            createBarButtonItem(imageName: "tablecells", tag: 2, disabled: true),
            createBarButtonItem(imageName: "camera", tag: 3, disabled: true),
            createBarButtonItem(imageName: "pencil.tip.crop.circle", tag: 4, disabled: true),
        ]

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        items = [flexibleSpace, buttons[0], flexibleSpace, buttons[1], flexibleSpace, buttons[2], flexibleSpace, buttons[3], flexibleSpace, buttons[4], flexibleSpace]
    }
    
    private func createBarButtonItem(imageName: String, tag: Int, disabled: Bool) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(
            image: UIImage(systemName: imageName),
            style: .plain,
            target: self,
            action: #selector(toolbarButtonTapped(_:))
        )
        
        barButtonItem.tag = tag
        barButtonItem.tintColor = .label
        barButtonItem.isEnabled = !disabled
        return barButtonItem
    }

    @objc private func toolbarButtonTapped(_ sender: UIBarButtonItem) {
        noteToolbarDelegate?.didTapToolbarButton(withTag: sender.tag)
    }
}

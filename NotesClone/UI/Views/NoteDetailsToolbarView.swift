//
//  NoteDetailsToolbarView.swift
//  NotesClone
//
//  Created by Selin Kayar on 13.07.24.
//

import UIKit

enum NoteDetailsToolbarAction {
    case formatting
    case checklist
    case tablecells
    case camera
    case pencilkit
}

protocol NoteDetailsToolbarDelegate: AnyObject {
    func didTapButton(action: NoteDetailsToolbarAction)
}

class NoteDetailsToolbarView: UIView {

    weak var delegate: NoteDetailsToolbarDelegate?

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var buttons: [UIButton] = {
        return [
            createButton(imageName: "textformat.alt", tag: 0, disabled: false),
            createButton(imageName: "checklist", tag: 1, disabled: true),
            createButton(imageName: "tablecells", tag: 2, disabled: true),
            createButton(imageName: "camera", tag: 3, disabled: true),
            createButton(imageName: "pencil.tip.crop.circle", tag: 4, disabled: true)
        ]
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemGray5
        
        addSubview(stackView)
        
        buttons.forEach { button in
            stackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func createButton(imageName: String, tag: Int, disabled: Bool) -> UIButton {
        let button = UIButton(type: .system)
        
        let image = UIImage(systemName: imageName)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular)
        
        button.tag = tag
        button.tintColor = .label
        button.isEnabled = !disabled
        button.alpha = disabled ? 0.5 : 1.0
        
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        return button
    }

    @objc func buttonPressed(_ sender: UIButton) {
        let action: NoteDetailsToolbarAction
        
        switch sender.tag {
        case 0:
            action = .formatting
        case 1:
            action = .checklist
        case 2:
            action = .tablecells
        case 3:
            action = .camera
        case 4:
            action = .pencilkit
        default:
            return
        }
        delegate?.didTapButton(action: action)
    }
}

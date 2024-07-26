//
//  FormatTextContainerView.swift
//  NotesClone
//
//  Created by Selin Kayar on 17.07.24.
//

import UIKit

protocol FormatTextContainerViewDelegate: AnyObject {
    func didUpdateTextFormatting(_ formatting: TextFormatting)
}

enum TextAttributeButtonStyle {
    case bold, italic, underlined

    var attributedString: NSAttributedString {
        switch self {
        case .bold:
            return attributedString(for: "B", attributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
        case .italic:
            return attributedString(for: "I", attributes: [.font: UIFont.italicSystemFont(ofSize: 18)])
        case .underlined:
            return attributedString(for: "U", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.systemFont(ofSize: 18)])
        }
    }

    private func attributedString(for text: String, attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: attributes)
    }
}

class FormatTextContainerView: UIView {
    
    weak var delegate: FormatTextContainerViewDelegate?

    private var currentFormatting: TextFormatting {
        didSet {
            if currentFormatting != oldValue {
                notifyDelegate()
            }
        }
    }
    
    private var textSizeView: FormatTextSizeView!
    private var selectedTextSizeStyle: FormatTextSizeStyle {
        didSet {
            currentFormatting.size = selectedTextSizeStyle.textStyle.pointSize
            styleChanged()
        }
    }
    
    private var buttons: [UIButton] = []
    private let textAttributeStackView = createStackView()
    
    init(with formatting: TextFormatting) {
        self.currentFormatting = formatting
        self.selectedTextSizeStyle = FormatTextSizeStyle.allCases.first { $0.textStyle.pointSize == formatting.size } ?? .body
        super.init(frame: .zero)
        configureTextSizeView()
        createButtons()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 2
        stackView.layer.cornerRadius = 10
        stackView.layer.cornerCurve = .continuous
        stackView.layer.masksToBounds = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func configureTextSizeView() {
        textSizeView = FormatTextSizeView(with: selectedTextSizeStyle)
        textSizeView.onStyleChanged = { [weak self] style in
            self?.selectedTextSizeStyle = style
        }
    }
    
    private func createButtons() {
        buttons = [
            createFormattingButton(title: TextAttributeButtonStyle.bold.attributedString, tag: 0),
            createFormattingButton(title: TextAttributeButtonStyle.italic.attributedString, tag: 1),
            createFormattingButton(title: TextAttributeButtonStyle.underlined.attributedString, tag: 2)
        ]
        
        buttons.forEach { button in
            updateButtonAppearance(button, isSelected: isSelected(button.tag))
            textAttributeStackView.addArrangedSubview(button)
            button.heightAnchor.constraint(equalTo: textAttributeStackView.heightAnchor).isActive = true
        }
    }
    
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        textSizeView.translatesAutoresizingMaskIntoConstraints = false

        addSubviews(textSizeView, textAttributeStackView)
    
        NSLayoutConstraint.activate([
            textSizeView.topAnchor.constraint(equalTo: topAnchor),
            textSizeView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textSizeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textSizeView.heightAnchor.constraint(equalToConstant: 44),
            
            textAttributeStackView.topAnchor.constraint(equalTo: textSizeView.bottomAnchor, constant: 8),
            textAttributeStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textAttributeStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textAttributeStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func createFormattingButton(title: NSAttributedString, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setAttributedTitle(title, for: .normal)
        button.tag = tag
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        return button
    }
    
    private func updateButtonAppearance(_ button: UIButton, isSelected: Bool) {
        button.backgroundColor = isSelected ? .systemYellow.darker(by: 12) : .tertiarySystemGroupedBackground
        button.setTitleColor(isSelected ? .white : .label, for: .normal)
    }
    
    private func isSelected(_ tag: Int) -> Bool {
        switch tag {
        case 0: return currentFormatting.isBold
        case 1: return currentFormatting.isItalic
        case 2: return currentFormatting.isUnderlined
        default: return false
        }
    }
    
    private func notifyDelegate() {
        delegate?.didUpdateTextFormatting(currentFormatting)
    }
    
    private func styleChanged() {
        switch selectedTextSizeStyle {
        case .title, .heading,  .subheading:
            currentFormatting.isBold = true
            updateButtonAppearance(buttons[0], isSelected: true)
        case .body,  .monostyled:
            currentFormatting.isBold = false
            updateButtonAppearance(buttons[0], isSelected: false)
        }
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            currentFormatting.isBold.toggle()
        case 1:
            currentFormatting.isItalic.toggle()
        case 2:
            currentFormatting.isUnderlined.toggle()
        default:
            break
        }
        updateButtonAppearance(sender, isSelected: isSelected(sender.tag))
    }
}

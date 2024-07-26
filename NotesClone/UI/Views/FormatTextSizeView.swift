//
//  FormatTextSizeView.swift
//  NotesClone
//
//  Created by Selin Kayar on 16.07.24.
//

import UIKit

enum FormatTextSizeStyle: String, CaseIterable {
    case title, heading, subheading, body, monostyled
    
    var name: String {
        return self.rawValue.capitalized
    }
    
    var textStyle: UIFont {
        switch self {
        case .title:
            return UIFont.systemFont(ofSize: 23)
        case .heading:
            return UIFont.systemFont(ofSize: 18)
        case .subheading:
            return UIFont.systemFont(ofSize: 15)
        case .body:
            return UIFont.systemFont(ofSize: 14)
        case .monostyled:
            return UIFont.systemFont(ofSize: 13)
        }
    }
}

class FormatTextSizeView: UIView {
        
    var onStyleChanged: ((FormatTextSizeStyle) -> Void)?
    
    var selectedStyle: FormatTextSizeStyle

    private var scrollView: UIScrollView!
    private var stackView: UIStackView!
    private var selectedButton: UIButton? {
        didSet {
            guard let button = selectedButton, selectedButton != oldValue else { return }
            if let index = stackView.arrangedSubviews.firstIndex(of: button), index < FormatTextSizeStyle.allCases.count {
                self.selectedStyle = FormatTextSizeStyle.allCases[index]
                onStyleChanged?(selectedStyle)
            }
        }
    }
    
    init(with selectedStyle: FormatTextSizeStyle) {
        self.selectedStyle = selectedStyle
        super.init(frame: .zero)
        setupScrollView()
        setupStackView()
        setupButtons(with: selectedStyle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupStackView() {
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func setupButtons(with selectedStyle: FormatTextSizeStyle) {
        for style in FormatTextSizeStyle.allCases {
            let button = UIButton(type: .system)
            
            if style == selectedStyle {
                setSelectedStyle(button)
            } else {
                button.setTitleColor(.label , for: .normal)
                button.backgroundColor = .clear
            }
            
            button.setTitle(style.name, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: style.textStyle.pointSize, weight: style != .body && style != .monostyled ? .bold : .regular)
            
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            button.layer.cornerRadius = 12
            button.layer.cornerCurve = .continuous
            button.layer.masksToBounds = true
            button.translatesAutoresizingMaskIntoConstraints = false
                        
            stackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    }
    
    private func setSelectedStyle(_ sender: UIButton) {
        if let selectedButton = self.selectedButton {
            selectedButton.backgroundColor = .clear
            selectedButton.setTitleColor(.label, for: .normal)
        }
        
        sender.backgroundColor = .systemYellow.darker(by: 12)
        sender.setTitleColor(.white, for: .normal)
        self.selectedButton = sender
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        setSelectedStyle(sender)
    }
}

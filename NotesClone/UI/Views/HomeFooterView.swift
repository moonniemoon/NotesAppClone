//
//  HomeFooterView.swift
//  NotesClone
//
//  Created by Selin Kayar on 16.07.24.
//

import UIKit

protocol HomeFooterDelegate: AnyObject {
    func imageTapped()
    func updateNoteCount(_ count: Int)
}

class HomeFooterView: UIView {
    
    weak var delegate: HomeFooterDelegate?
    private var blurEffectView: UIVisualEffectView!
    
    let notesCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.tintColor = .systemYellow.darker(by: 12)
        let image = UIImage(systemName: "square.and.pencil")?.withRenderingMode(.alwaysTemplate)
        imageView.image = image
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        createBlurredBackground()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(notesCountLabel, imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            imageView.widthAnchor.constraint(equalToConstant: 28),
            imageView.heightAnchor.constraint(equalToConstant: 28),
          
            notesCountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            notesCountLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    private func createBlurredBackground() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurEffectView)
        
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        sendSubviewToBack(blurEffectView)
    }
    
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        delegate?.imageTapped()
    }
}

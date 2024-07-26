//
//  CollapsibleTableViewHeader.swift
//  NotesClone
//
//  Created by Selin Kayar on 10.07.24.
//

import UIKit

protocol CollapsibleTableViewHeaderDelegate {
    func toggleSection(header: CollapsibleTableViewHeader)
}

class CollapsibleTableViewHeader: UITableViewHeaderFooterView {
    static let reuseID = String(describing: CollapsibleTableViewHeader.self)
    var delegate: CollapsibleTableViewHeaderDelegate?
    
    let titleLabel = UILabel()
    let arrowImageView = UIImageView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureLayout()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        arrowImageView.image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.tintColor = .systemYellow.darker(by: 12)
        arrowImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)

        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 14),
            arrowImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    @objc private func didTapHeader() {
        delegate?.toggleSection(header: self)
    }
    
    func setCollapsed(_ collapsed: Bool) {
        let angle: CGFloat = collapsed ? 0 : .pi / 2
        UIView.animate(withDuration: 0.2) {
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
}

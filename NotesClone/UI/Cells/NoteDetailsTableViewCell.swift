//
//  NoteDetailsTableViewCell.swift
//  NotesClone
//
//  Created by Selin Kayar on 7.07.24.
//

import UIKit

class NoteDetailsTableViewCell: UITableViewCell {
    
    static let reuseID = String(describing: NoteDetailsTableViewCell.self)
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(titleLabel, stackView)
        
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(subtitleLabel)
        addConstraints()
        
        dateLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        subtitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [titleLabel, dateLabel, subtitleLabel].forEach { label in
            label.text = nil
        }
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with note: Note) {
        titleLabel.text = note.title
        dateLabel.text = note.lastUpdated?.dateFormatter()
        subtitleLabel.text = note.additionalText
    }
}

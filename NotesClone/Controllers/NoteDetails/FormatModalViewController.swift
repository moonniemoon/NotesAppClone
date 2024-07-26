//
//  FormatModalViewController.swift
//  NotesClone
//
//  Created by Selin Kayar on 15.07.24.
//

import UIKit

protocol FormatModalViewControllerDelegate: AnyObject {
    func didUpdateTextFormatting(_ formatting: TextFormatting)
}

class FormatModalViewController: UIViewController {
    
    weak var delegate: FormatModalViewControllerDelegate?
    
    private var textFormatting: TextFormatting
    private var textFormattingView: FormatTextContainerView!
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        label.text = "Format"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var closeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "x.circle.fill")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, closeImageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.darkText.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 5
        view.clipsToBounds = false
        return view
    }()

    var maximumContainerHeight: CGFloat = 0
    var defaultHeight: CGFloat = 0
    var dismissibleHeight: CGFloat = 0
    var currentContainerHeight: CGFloat = 0

    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    
    init(textFormatting: TextFormatting) {
        self.textFormatting = textFormatting
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        let screenHeight = UIScreen.main.bounds.height
        defaultHeight = screenHeight * 0.25
        maximumContainerHeight = screenHeight * 0.3
        dismissibleHeight = screenHeight * 0.125
        currentContainerHeight = defaultHeight

        textFormattingView = FormatTextContainerView(with: textFormatting)
        textFormattingView.delegate = self
        configureConstraints()
        configurePanGesture()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeImageTapped(_:)))
        closeImageView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
    }
    
    private func configureConstraints() {
        view.addSubviews(containerView)
        containerView.addSubviews(headerStackView, textFormattingView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            closeImageView.widthAnchor.constraint(equalToConstant: 28),
            closeImageView.heightAnchor.constraint(equalToConstant: 28),
                        
            headerStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            headerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            textFormattingView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 16),
            textFormattingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textFormattingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textFormattingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])

        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    private func animatePresentContainer() {
        UIView.animate(withDuration: 0.2) {
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateDismissView() {
        UIView.animate(withDuration: 0.2) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
        self.dismiss(animated: true)
    }
    
    private func configurePanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    private func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerViewHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
    
    @objc private func closeImageTapped(_ sender: UITapGestureRecognizer) {
        animateDismissView()
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        //let isDraggingDown = translation.y > 0
        let newHeight = currentContainerHeight - translation.y

        switch gesture.state {
        case .changed:
            if newHeight < maximumContainerHeight {
                containerViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            }
        case .ended:
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            } else {
                animateContainerHeight(defaultHeight)
            }
        default:
            break
        }
    }
}

extension FormatModalViewController: FormatTextContainerViewDelegate {
    func didUpdateTextFormatting(_ formatting: TextFormatting) {
        delegate?.didUpdateTextFormatting(formatting)
    }
}

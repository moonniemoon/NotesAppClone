//
//  BlurryBackgroundView.swift
//  NotesClone
//
//  Created by Selin Kayar on 7.07.24.
//

import UIKit

class BlurryBackgroundView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let blurEffect = UIBlurEffect(style: .systemThickMaterial)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = bounds
        addSubview(blurredEffectView)
    }
}

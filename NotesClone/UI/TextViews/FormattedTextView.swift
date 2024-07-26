//
//  FormattedTextView.swift
//  NotesClone
//
//  Created by Selin Kayar on 20.07.24.
//

import UIKit

class FormattedTextView: UITextView {
    
    private let defaultFontSize: CGFloat = 14
    private let defaultFont: UIFont = UIFont.systemFont(ofSize: 14)
    private let defaultTextColor: UIColor = .label
    
    override var text: String! {
        didSet {
            updateAttributedText()
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            updateTypingAttributes()
        }
    }
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        configureTextView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    private func configureTextView() {
        font = defaultFont
        textColor = defaultTextColor
        isScrollEnabled = true
        showsVerticalScrollIndicator = true
        showsHorizontalScrollIndicator = false
        allowsEditingTextAttributes = true
        textDragInteraction?.isEnabled = true
        tintColor = .systemYellow.darker(by: 12)
        textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        backgroundColor = .systemBackground
        autocorrectionType = .no
        
        updateTextAttributes(fontSize: 23, isBold: true, isItalic: false, isUnderlined: false)
    }
}


extension FormattedTextView {
    
    // MARK: - Attributed Text Handling
    
    func attributedTextData() -> Data? {
        guard let data = try? attributedText.data(from: NSRange(location: 0, length: attributedText.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]) else {
            return nil
        }
        return data
    }
    
    private func updateAttributedText() {
        attributedText = NSAttributedString(string: text, attributes: typingAttributes)
    }
    
    private func updateTypingAttributes() {
        if let font = typingAttributes[.font] as? UIFont {
            typingAttributes[.font] = font
        } else {
            typingAttributes[.font] = defaultFont
        }
        
        if let color = typingAttributes[.foregroundColor] as? UIColor {
            typingAttributes[.foregroundColor] = color
        } else {
            typingAttributes[.foregroundColor] = defaultTextColor
        }
    }
    
    // MARK: - Formatting Methods
    
    func updateTextAttributes(_ range: NSRange? = nil, fontSize: CGFloat? = nil, isBold: Bool, isItalic: Bool, isUnderlined: Bool) {
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        let finalFontSize = fontSize ?? self.font?.pointSize ?? 14
        
        var font: UIFont = UIFont.systemFont(ofSize: finalFontSize)
        
        if isBold && isItalic {
            let boldFont = UIFont.systemFont(ofSize: finalFontSize, weight: .bold)
            let fontDescriptor = boldFont.fontDescriptor.withSymbolicTraits([.traitItalic])
            font = UIFont(descriptor: fontDescriptor!, size: finalFontSize)
        } else if isBold {
            font = UIFont.systemFont(ofSize: finalFontSize, weight: .bold)
        } else if isItalic {
            font = UIFont.italicSystemFont(ofSize: finalFontSize)
        } else {
            font = UIFont.systemFont(ofSize: finalFontSize)
        }
        
        attributes[.font] = font
        attributes[.foregroundColor] = UIColor.label
        
        if isUnderlined {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributes[.paragraphStyle] = paragraphStyle
        
        if let range = range {
            self.textStorage.beginEditing()
            self.textStorage.setAttributes(attributes, range: range)
            self.textStorage.endEditing()

            self.typingAttributes = attributes

        } else {
            self.typingAttributes = attributes
        }
    }
    
    func updateFormattingForRange(fontSize: CGFloat? = nil, isBold: Bool, isItalic: Bool, isUnderlined: Bool) {
        guard let text = self.text, let range = self.currentLineRange() else { return }
        
        let fullRange = NSRange(location: 0, length: text.count)
        
        if range.location > fullRange.length {
            return
        }
        
        let paragraphRange = (text as NSString).paragraphRange(for: range)
        updateTextAttributes(paragraphRange, fontSize: fontSize, isBold: isBold, isItalic: isItalic, isUnderlined: isUnderlined)
    }
    
    func revertToDefaultFormatting() {
        typingAttributes = [
            .font: defaultFont,
            .foregroundColor: defaultTextColor
        ]
    }

    // MARK: - Helper Methods
    
    func currentLineRange() -> NSRange? {
        guard let text = self.text else { return nil }
        //let textRange = NSRange(location: 0, length: text.count)
        let currentLineRange = (text as NSString).lineRange(for: self.selectedRange)
        //let intersection = NSIntersectionRange(currentLineRange, textRange)
        return currentLineRange
    }
    
    func getCurrentTextAttributes() -> TextFormatting {
        let selectedRange = self.selectedRange
        let maxLength = self.textStorage.length
        
        guard maxLength > 0 else {
            return TextFormatting(size: self.font?.pointSize ?? 14, isBold: false, isItalic: false, isUnderlined: false)
        }
        
        /// Important: If range out of bounds, an uncaught exception occurs. NSConcreteTextStorage: Range or index out of bounds
        let location = max(0, min(selectedRange.location, maxLength - 1))
        
        let rangeToCheck: NSRange
        if selectedRange.length > 0 {
            rangeToCheck = selectedRange
        } else {
            rangeToCheck = NSRange(location: location, length: 1)
        }
        
        let validRange = NSRange(location: rangeToCheck.location, length: min(rangeToCheck.length, maxLength - rangeToCheck.location))
        
        let attributes = (validRange.length > 0) ? self.textStorage.attributes(at: validRange.location, effectiveRange: nil) : [:]
        return extractAttributes(from: attributes)
    }
    
    
    private func extractAttributes(from attributes: [NSAttributedString.Key: Any]) -> TextFormatting {
        let font = attributes[.font] as? UIFont
        let fontSize = font?.pointSize ?? self.font?.pointSize ?? 14
        let isBold = font?.fontDescriptor.symbolicTraits.contains(.traitBold) ?? false
        let isItalic = font?.fontDescriptor.symbolicTraits.contains(.traitItalic) ?? false
        let isUnderlined = (attributes[.underlineStyle] as? Int) == NSUnderlineStyle.single.rawValue
        
        return TextFormatting(size: fontSize, isBold: isBold, isItalic: isItalic, isUnderlined: isUnderlined)
    }
}

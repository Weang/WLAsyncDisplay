//
//  NSMutableAttributedString+Ext.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/2.
//

import UIKit

// Range
extension NSMutableAttributedString {
    
    var range: NSRange? {
        if let range = string.range(of: string) {
            return NSRange.init(range, in: string)
        }
        return nil
    }
    
}

// TextColor
extension NSMutableAttributedString {
    
    func setTextColor(color: UIColor) {
        setTextColor(color: color, text: string)
    }
    
    func setTextColor(color: UIColor, text: String) {
        guard let range = string.range(of: text) else {
            return
        }
        setTextColor(color: color, range: NSRange.init(range, in: string))
    }
    
    func setTextColor(color: UIColor, range: NSRange) {
        self.addAttribute(.foregroundColor, value: color, range: range)
    }
    
}

// Font
extension NSMutableAttributedString {
    
    func setFont(font: UIFont) {
        setFont(font: font, text: string)
    }
    
    func setFont(font: UIFont, text: String) {
        guard let range = string.range(of: text) else {
            return
        }
        setFont(font: font, range: NSRange.init(range, in: string))
    }
    
    func setFont(font: UIFont, range: NSRange) {
        self.addAttribute(.font, value: font, range: range)
    }
    
}

// textAlignment
extension NSMutableAttributedString {
    
    func setTextAlignment(textAlignment: NSTextAlignment) {
        setTextAlignment(textAlignment: textAlignment, text: string)
    }
    
    func setTextAlignment(textAlignment: NSTextAlignment, text: String) {
        guard let range = string.range(of: text) else {
            return
        }
        setTextAlignment(textAlignment: textAlignment, range: NSRange.init(range, in: string))
    }
    
    func setTextAlignment(textAlignment: NSTextAlignment, range: NSRange) {
        self.enumerateAttribute(NSAttributedString.Key.paragraphStyle,
                                in: range, options: .init(rawValue: 0)) { (value, subRange, _) in
            let style: NSMutableParagraphStyle
            if let currentStyle = value as? NSMutableParagraphStyle {
                style = currentStyle
            } else {
                style = NSMutableParagraphStyle()
            }
            style.alignment = textAlignment
            setParagraphStyle(paragraphStyle: style, range: subRange)
        }
    }
    
}

// lineSpacing
extension NSMutableAttributedString {
    
    func setLineSpacing(lineSpacing: CGFloat) {
        setLineSpacing(lineSpacing: lineSpacing, text: string)
    }
    
    func setLineSpacing(lineSpacing: CGFloat, text: String) {
        guard let range = string.range(of: text) else {
            return
        }
        setLineSpacing(lineSpacing: lineSpacing, range: NSRange.init(range, in: string))
    }
    
    func setLineSpacing(lineSpacing: CGFloat, range: NSRange) {
        self.enumerateAttribute(NSAttributedString.Key.paragraphStyle,
                                in: range, options: .init(rawValue: 0)) { (value, subRange, _) in
            let style: NSMutableParagraphStyle
            if let currentStyle = value as? NSMutableParagraphStyle {
                style = currentStyle
            } else {
                style = NSMutableParagraphStyle()
            }
            style.lineSpacing = lineSpacing
            setParagraphStyle(paragraphStyle: style, range: subRange)
        }
    }
    
}

//lineBreakMode
extension NSMutableAttributedString {
    
    func setLineBreakMode(lineBreakMode: NSLineBreakMode) {
        setLineBreakMode(lineBreakMode: lineBreakMode, text: string)
    }
    
    func setLineBreakMode(lineBreakMode: NSLineBreakMode, text: String) {
        guard let range = string.range(of: text) else {
            return
        }
        setLineBreakMode(lineBreakMode: lineBreakMode, range: NSRange.init(range, in: string))
    }
    
    func setLineBreakMode(lineBreakMode: NSLineBreakMode, range: NSRange) {
        self.enumerateAttribute(NSAttributedString.Key.paragraphStyle,
                                in: range, options: .init(rawValue: 0)) { (value, subRange, _) in
            let style: NSMutableParagraphStyle
            if let currentStyle = value as? NSMutableParagraphStyle {
                style = currentStyle
            } else {
                style = NSMutableParagraphStyle()
            }
            style.lineBreakMode = lineBreakMode
            setParagraphStyle(paragraphStyle: style, range: subRange)
        }
    }
    
}

// underlineStyle
extension NSMutableAttributedString {
    
    func setUnderlineStyle(underlineStyle: NSUnderlineStyle) {
        setUnderlineStyle(underlineStyle: underlineStyle, text: string)
    }
    
    func setUnderlineStyle(underlineStyle: NSUnderlineStyle, text: String) {
        guard let range = string.range(of: text) else {
            return
        }
        setUnderlineStyle(underlineStyle: underlineStyle, range: NSRange.init(range, in: string))
    }
    
    func setUnderlineStyle(underlineStyle: NSUnderlineStyle, range: NSRange) {
        self.addAttribute(.underlineStyle, value: underlineStyle.rawValue, range: range)
    }
    
}

// underlineColor
extension NSMutableAttributedString {
    
    func setUnderlineColor(underlineColor: UIColor) {
        setUnderlineColor(underlineColor: underlineColor, text: string)
    }
    
    func setUnderlineColor(underlineColor: UIColor, text: String) {
        guard let range = string.range(of: text) else {
            return
        }
        setUnderlineColor(underlineColor: underlineColor, range: NSRange.init(range, in: string))
    }
    
    func setUnderlineColor(underlineColor: UIColor, range: NSRange) {
        self.addAttribute(.underlineColor, value: underlineColor, range: range)
    }
    
}

// NSParagraphStyle
extension NSMutableAttributedString {
    
    func setParagraphStyle(paragraphStyle: NSParagraphStyle, range: NSRange) {
        self.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
    }
}

//
//  NSMutableAttributedString+BackgroundColor.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/8.
//

import UIKit

extension NSMutableAttributedString {
    
    func addBackgroundColorAt(range: NSRange, backgroundColor: UIColor, cornerRadius: CGFloat = 2) {
        let textBackgroundColor = WLTextBackgroundColor()
        textBackgroundColor.backgroundColor = backgroundColor
        textBackgroundColor.range = range
        textBackgroundColor.cornerRadius = cornerRadius
        self.addAttribute(WLAttributedStringKey.backgroundColor, value: textBackgroundColor, range: range)
    }
    
}

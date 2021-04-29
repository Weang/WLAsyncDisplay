//
//  NSMutableAttributedString+Highlight.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/7.
//

import UIKit

extension NSMutableAttributedString {
    
    // 添加高亮
    func addLinkAt(range: NSRange, linkColor: UIColor, highLightColor: UIColor, userInfo: [String: Any]?) {
        let highlight = WLTextHighlight()
        highlight.range = range
        highlight.linkColor = linkColor
        highlight.hightlightColor = highLightColor
        highlight.userInfo = userInfo
        addAttribute(WLAttributedStringKey.link, value: highlight, range: range)
        addAttribute(NSAttributedString.Key.foregroundColor, value: linkColor, range: range)
    }
    
}

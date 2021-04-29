//
//  NSMutableAttributedString+Attachment.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/4.
//

import UIKit

extension NSMutableAttributedString {
    
    // 创建带附件的富文本
    class func createAttachmentStringWith(contents: WLTextAttachmentProtocol,
                                          ascent: CGFloat,
                                          descent: CGFloat,
                                          width: CGFloat) -> NSMutableAttributedString {
        
        // 创建附件
        let attachment = WLTextAttachment.init(contents: contents)
        
        // 创建空字符串
        var objectReplacementChar = unichar(0xfffc)
        let contentString = NSString.init(characters: &objectReplacementChar, length: 1) as String
        let space = NSMutableAttributedString.init(string: contentString)
        space.addAttribute(WLAttributedStringKey.attachment,
                           value: attachment,
                           range: NSRange(location: 0, length: space.length))
        
        // 创建CTRunDelegate
        let delegate = WLTextRunDelegate()
        delegate.ascent = ascent
        delegate.descent = descent
        delegate.width = width
        if let runDelegate = delegate.runDelegate {
            CFAttributedStringSetAttribute(space, CFRange(location: 0, length: space.length), kCTRunDelegateAttributeName, runDelegate)
        }
        return space
    }
    
}

//
//  WLTextAttachment.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/4.
//

import UIKit

// 附件信息，可以显示任何遵守WLTextAttachmentProtocol的类
public class WLTextAttachment: NSObject {
    
    let attachment: WLTextAttachmentType
    var range: NSRange = NSRange(location: 0, length: 0)
    var rect: CGRect = .zero
    
    var contentEdgeInsets = UIEdgeInsets.zero
    
    init(attachment: WLTextAttachmentType) {
        self.attachment = attachment
    }
    
}

public extension NSMutableAttributedString {
    
    convenience init(attachment: WLTextAttachmentType, ascent: CGFloat, descent: CGFloat, width: CGFloat) {
        // 创建附件
        let attachment = WLTextAttachment(attachment: attachment)
        
        // 创建空字符串
        var objectReplacementChar = unichar(0xfffc)
        let contentString = NSString(characters: &objectReplacementChar, length: 1) as String
        let space = NSMutableAttributedString(string: contentString)
        space.addAttribute(WLAttributedStringKey.attachment, value: attachment, range: NSRange(location: 0, length: space.length))
        
        // 创建CTRunDelegate
        let delegate = WLTextRunDelegate()
        delegate.ascent = ascent
        delegate.descent = descent
        delegate.width = width
        if let runDelegate = delegate.runDelegate {
            CFAttributedStringSetAttribute(space, CFRange(location: 0, length: space.length), kCTRunDelegateAttributeName, runDelegate)
        }
        self.init(attributedString: space)
    }
    
}

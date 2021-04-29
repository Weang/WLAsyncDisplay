//
//  WLTextNode.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/2.
//

import UIKit

public class WLTextNode: NSObject {
    
    public var frame: CGRect = .zero {
        didSet {
            self.createTextLayout()
        }
    }
    
    public var text: String? {
        set {
            guard let text = newValue else {
                attributedText = nil
                return
            }
            attributedText = NSMutableAttributedString.init(string: text)
            createAttributedText()
            createTextLayout()
        }
        get {
            return attributedText?.string
        }
    }
    
    public var attributedText: NSMutableAttributedString? = nil {
        didSet {
            createTextLayout()
        }
    }
    
    public var font: UIFont = UIFont.systemFont(ofSize: 18) {
        didSet {
            attributedText?.setFont(font: font)
            createTextLayout()
        }
    }
    
    public var textColor: UIColor = .black {
        didSet {
            attributedText?.setTextColor(color: textColor)
            createTextLayout()
        }
    }
    
    public var maxNumberOfLines: Int = 0 {
        didSet {
            createTextLayout()
        }
    }
    
    public var textAlignment: NSTextAlignment = .left {
        didSet {
            attributedText?.setTextAlignment(textAlignment: textAlignment)
            createTextLayout()
        }
    }
    
    public var lineSpacing: CGFloat = 0 {
        didSet {
            attributedText?.setLineSpacing(lineSpacing: lineSpacing)
            createTextLayout()
        }
    }
    
    public var lineBreakMode: NSLineBreakMode = .byWordWrapping {
        didSet {
            attributedText?.setLineBreakMode(lineBreakMode: lineBreakMode)
            createTextLayout()
        }
    }
    
    public var underlineColor: UIColor = .clear {
        didSet {
            attributedText?.setUnderlineColor(underlineColor: underlineColor)
            createTextLayout()
        }
    }
    
    public var underlineStyle: NSUnderlineStyle = NSUnderlineStyle.init(rawValue: 0) {
        didSet {
            attributedText?.setUnderlineStyle(underlineStyle: underlineStyle)
            createTextLayout()
        }
    }
    
    public var truncationToken: WLTruncationToken? = nil {
        didSet {
            createTextLayout()
        }
    }
    
    public var isDebug: Bool = false {
        didSet {
            createTextLayout()
        }
    }
    
    public var textLayout: WLTextLayout?
    
    func createAttributedText() {
        attributedText?.setFont(font: font)
        attributedText?.setTextColor(color: textColor)
        attributedText?.setTextAlignment(textAlignment: textAlignment)
        attributedText?.setLineSpacing(lineSpacing: lineSpacing)
        attributedText?.setLineBreakMode(lineBreakMode: lineBreakMode)
        attributedText?.setUnderlineColor(underlineColor: underlineColor)
        attributedText?.setUnderlineStyle(underlineStyle: underlineStyle)
    }
    
    // 添加附件信息
    public func replaceTextWithAttachment(contents: WLTextAttachmentProtocol,
                                   size: CGSize,
                                   range: NSRange) {
        let ascent = size.height
        let descent: CGFloat = 0
        
        let attachmentString = NSMutableAttributedString.createAttachmentStringWith(contents: contents,
                                                                                    ascent: ascent,
                                                                                    descent: descent,
                                                                                    width: size.width)
        
        self.attributedText?.replaceCharacters(in: range, with: attachmentString)
        
        createTextLayout()
    }
    
    // 添加点击高亮事件
    public func addLinkAt(range: NSRange,
                   linkColor: UIColor,
                   highLightColor: UIColor,
                   userInfo: [String: Any]?) {
        attributedText?.addLinkAt(range: range,
                                  linkColor: linkColor,
                                  highLightColor: highLightColor,
                                  userInfo: userInfo)
        createTextLayout()
    }
    
    // 添加背景颜色
    public func addBackgroundColorAt(range: NSRange,
                              backgroundColor: UIColor,
                              cornerRadius: CGFloat = 2) {
        attributedText?.addBackgroundColorAt(range: range,
                                             backgroundColor: backgroundColor,
                                             cornerRadius: cornerRadius)
        createTextLayout()
    }
    
    public func createTextLayout() {
        guard frame.size.width > 0,
              let attributedText = attributedText else {
            return
        }
        let container = WLTextContainer.init(containerSize: self.size)
        container.maxNumberOfLines = self.maxNumberOfLines
        textLayout = WLTextLayout.init(container: container, attributedString: attributedText)
        textLayout?.truncationToken = truncationToken
        textLayout?.isDebug = isDebug
    }
    
    public func append(node: WLTextNode) {
        if let attributedText = node.attributedText {
            if self.attributedText == nil {
                self.attributedText = attributedText
            } else {
                self.attributedText?.append(attributedText)
                createTextLayout()
            }
        }
    }
}

extension WLTextNode  {
    
    public var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame.size = newValue
        }
    }
    
    public var position: CGPoint {
        return frame.origin
    }
    
    public var width: CGFloat {
        return size.width
    }
    
    public var height: CGFloat {
        return size.height
    }
    
    public var textContentSize: CGSize {
        guard let textLayout = self.textLayout else {
            return .zero
        }
        return textLayout.suggestSize
    }
    
    public var textContentWidth: CGFloat {
        return textContentSize.width
    }
    
    public var textContentHeight: CGFloat {
        return textContentSize.height
    }
    
    public var top: CGFloat {
        guard let textLayout = self.textLayout else {
            return 0
        }
        return textLayout.cgPathBox.origin.y + position.y
    }
    
    public var left: CGFloat {
        guard let textLayout = self.textLayout else {
            return 0
        }
        return textLayout.cgPathBox.origin.x + position.x
    }
    
    public var bottom: CGFloat {
        return top + textContentHeight
    }
    
    public var right: CGFloat {
        return left + textContentWidth
    }
    
}

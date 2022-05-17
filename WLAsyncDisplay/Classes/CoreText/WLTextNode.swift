//
//  WLTextNode.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/2.
//

import UIKit

public class WLTextNode: NSObject {
    
    public var width: CGFloat = 0 {
        didSet {
            createTextLayout()
        }
    }
    
    public var textSuggestSize: CGSize {
        guard let textLayout = self.textLayout else {
            return .zero
        }
        return textLayout.suggestSize
    }
    
    public var text: String? {
        set {
            guard let text = newValue else {
                attributedText = nil
                return
            }
            attributedText = NSMutableAttributedString(string: text)
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
            createAttributedText()
            createTextLayout()
        }
    }
    
    public var textColor: UIColor = .black {
        didSet {
            createAttributedText()
            createTextLayout()
        }
    }
    
    public var textAlignment: NSTextAlignment = .left {
        didSet {
            createAttributedText()
            createTextLayout()
        }
    }
    
    public var lineSpacing: CGFloat = 0 {
        didSet {
            createAttributedText()
            createTextLayout()
        }
    }
    
    public var lineBreakMode: NSLineBreakMode = .byWordWrapping {
        didSet {
            createAttributedText()
            createTextLayout()
        }
    }
    
    public var underlineColor: UIColor = .clear {
        didSet {
            createAttributedText()
            createTextLayout()
        }
    }
    
    public var underlineStyle: NSUnderlineStyle = NSUnderlineStyle(rawValue: 0) {
        didSet {
            createAttributedText()
            createTextLayout()
        }
    }
    
    public var maxNumberOfLines: Int = 0 {
        didSet {
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
    
    /// 创建富文本
    func createAttributedText() {
        guard let attributedText = attributedText,
              let range = attributedText.string.range(of: attributedText.string) else {
            return
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = lineBreakMode
        
        let attrs: [NSAttributedString.Key: Any] = [.font: font,
                                                    .foregroundColor: textColor,
                                                    .underlineColor: underlineColor,
                                                    .underlineStyle: underlineStyle,
                                                    .paragraphStyle: paragraphStyle]
        
        attributedText.addAttributes(attrs, range: NSRange(range, in: attributedText.string))
    }
    
    /// 添加附件信息
    public func replaceTextWithAttachment(attachment: WLTextAttachmentType, size: CGSize, range: NSRange) {
        let ascent = size.height
        let descent: CGFloat = 0
        let width = size.width
        let attachmentString = NSMutableAttributedString(attachment: attachment, ascent: ascent, descent: descent, width: width)
        self.attributedText?.replaceCharacters(in: range, with: attachmentString)
        createTextLayout()
    }
    
    /// 添加点击高亮
    /// - Parameters:
    ///   - range: 高亮
    ///   - linkColor: 文字颜色
    ///   - underlineStyle: 下划线样式
    ///   - highLightColor: 点击高亮的背景颜色
    ///   - userInfo: 携带的额外信息
    public func addLinkAt(range: NSRange, linkColor: UIColor, underlineStyle: NSUnderlineStyle = NSUnderlineStyle(rawValue: 0), highLightColor: UIColor, userInfo: [String: Any]? = nil) {
        let highlight = WLTextHighlight()
        highlight.range = range
        highlight.linkColor = linkColor
        highlight.hightlightColor = highLightColor
        highlight.userInfo = userInfo
        attributedText?.addAttribute(WLAttributedStringKey.link, value: highlight, range: range)
        attributedText?.addAttribute(.foregroundColor, value: linkColor, range: range)
        attributedText?.addAttribute(.underlineStyle, value: underlineStyle, range: range)
        createTextLayout()
    }
    
    /// 添加背景颜色
    /// - Parameters:
    ///   - range: 背景颜色范围
    ///   - backgroundColor: 背景颜色
    ///   - cornerRadius: 背景颜色圆角
    public func addBackgroundColorAt(range: NSRange, backgroundColor: UIColor, cornerRadius: CGFloat = 2) {
        let textBackgroundColor = WLTextBackgroundColor()
        textBackgroundColor.backgroundColor = backgroundColor
        textBackgroundColor.range = range
        textBackgroundColor.cornerRadius = cornerRadius
        attributedText?.addAttribute(WLAttributedStringKey.backgroundColor, value: textBackgroundColor, range: range)
        createTextLayout()
    }
    
    
    /// 合并多个Node
    public func append(node: WLTextNode) {
        guard let attributedText = node.attributedText else { return }
        if self.attributedText == nil {
            self.attributedText = attributedText
        } else {
            self.attributedText?.append(attributedText)
            createTextLayout()
        }
    }
    
    func createTextLayout() {
        guard width > 0, let attributedText = attributedText else {
            return
        }
        textLayout = WLTextLayout(containerSize: CGSize(width: width, height: CGFloat(MAXFLOAT)), attributedString: attributedText)
        textLayout?.truncationToken = truncationToken
        textLayout?.maxNumberOfLines = maxNumberOfLines
        textLayout?.isDebug = isDebug
        textLayout?.createTextLayout()
    }
    
}

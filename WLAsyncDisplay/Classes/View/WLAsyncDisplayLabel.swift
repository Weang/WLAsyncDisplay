//
//  WLAsyncDisplayLabel.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/2.
//

import UIKit

public protocol WLAsyncDisplayLabelDelegate: AnyObject {
    
    /// 点击高亮回调代理
    func asyncDisplayLabel(_ label: WLAsyncDisplayLabel, didClickAtLink userInfo: [String: Any]?)
    
    /// 点击截断文字回调代理
    func asyncDisplayLabelDidClickAtTruncation(_ label: WLAsyncDisplayLabel)
    
    /// 点击正则高亮文字回调代理
    /// - Parameters:
    ///   - type: 正则类型
    ///   - content: 正则文字
    func asyncDisplayLabel(_ label: WLAsyncDisplayLabel, didClickAtRegularExpression type: WLRegularExpression.RegularType, content: String)
    
}

extension WLAsyncDisplayLabelDelegate {
    
    public func asyncDisplayLabel(_ label: WLAsyncDisplayLabel, didClickAtLink userInfo: [String: Any]?) { }
    public func asyncDisplayLabelDidClickAtTruncation(_ label: WLAsyncDisplayLabel) { }
    public func asyncDisplayLabel(_ label: WLAsyncDisplayLabel, didClickAtRegularExpression type: WLRegularExpression.RegularType, content: String) { }
    
}

open class WLAsyncDisplayLabel: UIView {
    
    public weak var delegate: WLAsyncDisplayLabelDelegate?
    
    // 是否异步绘制，默认是true
    public var displaysAsynchronously = true {
        didSet {
            asyncDisplayLayer?.displaysAsynchronously = displaysAsynchronously
        }
    }
    
    public var textNode: WLTextNode? {
        didSet {
            asyncDisplayLayer?.textNode = textNode
            layer.setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }
    
    var asyncDisplayLayer: WLAsyncDisplayLayer? {
        layer as? WLAsyncDisplayLayer
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.contentsScale = UIScreen.main.scale
        asyncDisplayLayer?.contentView = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override class var layerClass: AnyClass {
        return WLAsyncDisplayLayer.self
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self),
              let textNode = self.textNode else {
            super.touchesBegan(touches, with: event)
            return
        }
        if let highlight = searchTextHighlightIn(node: textNode, touchPoint: touchPoint) {
            textNode.textLayout?.highlight = highlight
            displayImmediately()
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard textNode?.textLayout?.highlight != nil else {
            super.touchesEnded(touches, with: event)
            return
        }
        let highlight = textNode?.textLayout?.highlight
        
        textNode?.textLayout?.highlight = nil
        displayImmediately()
        
        if let value = highlight?.userInfo?[WLAttributedStringKey.regularExpression.rawValue] as? Bool, value,
           let type = highlight?.userInfo?["type"] as? String,
           let regularType = WLRegularExpression.RegularType(rawValue: type),
           let content = highlight?.userInfo?["content"] as? String {
            delegate?.asyncDisplayLabel(self, didClickAtRegularExpression: regularType, content: content)
            return
        }
        if let value = highlight?.userInfo?[WLAttributedStringKey.truncationToken.rawValue] as? Bool, value {
            delegate?.asyncDisplayLabelDidClickAtTruncation(self)
            return
        }
        
        delegate?.asyncDisplayLabel(self, didClickAtLink: highlight?.userInfo)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        textNode?.textLayout?.highlight = nil
        displayImmediately()
    }
    
    public func searchTextHighlightIn(node: WLTextNode, touchPoint: CGPoint) -> WLTextHighlight? {
        guard let textLayout = node.textLayout else {
            return nil
        }
        for highlight in textLayout.textHighlights.reversed() {
            for position in highlight.positions {
                let adjustRect = CGRect(x: position.origin.x, y: position.origin.y, width: position.size.width, height: position.size.height)
                if adjustRect.contains(touchPoint) {
                    return highlight
                }
            }
        }
        return nil
    }
    
    public func displayImmediately() {
        asyncDisplayLayer?.displayImmediately()
    }
    
    public override var intrinsicContentSize: CGSize {
        return textNode?.textSuggestSize ?? .zero
    }
    
}

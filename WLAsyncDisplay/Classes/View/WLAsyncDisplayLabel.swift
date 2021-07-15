//
//  WLAsyncDisplayLabel.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/2.
//

import UIKit

public protocol WLAsyncDisplayLabelDelegate: class {
    
    /// 图片加载完成后需要重新布局
    func asyncDisplayViewShouldLayout(_ view: WLAsyncDisplayLabel)
    
    /// 点击高亮回调代理
    func asyncDisplayView(_ view: WLAsyncDisplayLabel, didClickAtLink userInfo: [String: Any]?)
    
    /// 点击截断文字回调代理
    func asyncDisplayViewDidClickAtTruncation(_ view: WLAsyncDisplayLabel)
    
    /// 点击正则高亮文字回调代理
    /// - Parameters:
    ///   - type: 正则类型
    ///   - content: 正则文字
    func asyncDisplayView(_ view: WLAsyncDisplayLabel, didClickAtRegularExpression type: WLRegularExpression.RegularType, content: String)
    
}

extension WLAsyncDisplayLabelDelegate {
    
    public func asyncDisplayViewShouldLayout(_ view: WLAsyncDisplayLabel) { }
    public func asyncDisplayView(_ view: WLAsyncDisplayLabel, didClickAtLink userInfo: [String: Any]?) { }
    public func asyncDisplayViewDidClickAtTruncation(_ view: WLAsyncDisplayLabel) { }
    public func asyncDisplayView(_ view: WLAsyncDisplayLabel, didClickAtRegularExpression type: WLRegularExpression.RegularType, content: String) { }
    
}

open class WLAsyncDisplayLabel: UIView {
    
    public weak var delegate: WLAsyncDisplayLabelDelegate?
    
    // 是否异步绘制，默认是true
    public var displaysAsynchronously = true {
        didSet {
            asyncDisplayLayer.displaysAsynchronously = displaysAsynchronously
        }
    }
    
    public var textNode: WLTextNode? {
        didSet {
            self.layer.setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }
    
    var asyncDisplayLayer: WLAsyncDisplayLayer {
        return self.layer as! WLAsyncDisplayLayer
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.contentsScale = UIScreen.main.scale
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
        if let highlight = self.searchTextHighlightIn(node: textNode, touchPoint: touchPoint) {
            textNode.textLayout?.highlightNodeOrgin = textNode.frame.origin
            textNode.textLayout?.highlight = highlight
        }
        if textNode.textLayout?.highlight != nil {
            displayHighlight()
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard textNode?.textLayout?.highlight != nil else {
            super.touchesEnded(touches, with: event)
            return
        }
        let highlight = textNode?.textLayout?.highlight
        textNode?.textLayout?.highlight = nil
        displayHighlight()
        
        if let value = highlight?.userInfo?[WLTruncationToken.highlightKey] as? Bool,
           value {
            delegate?.asyncDisplayViewDidClickAtTruncation(self)
        } else if let key = highlight?.userInfo?.keys.first,
                  let type = WLRegularExpression.RegularType.init(rawValue: key),
                  let content = highlight?.userInfo?[type.rawValue] as? String {
            delegate?.asyncDisplayView(self, didClickAtRegularExpression: type, content: content)
        } else {
            delegate?.asyncDisplayView(self, didClickAtLink: highlight?.userInfo)
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        textNode?.textLayout?.highlight = nil
        displayHighlight()
    }
    
    public func searchTextHighlightIn(node: WLTextNode, touchPoint: CGPoint) -> WLTextHighlight? {
        guard let textLayout = node.textLayout else { return nil }
        let nodeOrginPoint = node.frame.origin
        for highlight in textLayout.textHighlights {
            for position in highlight.positions {
                let adjustRect = CGRect(x: position.origin.x + nodeOrginPoint.x,
                                        y: position.origin.y + nodeOrginPoint.y,
                                        width: position.size.width,
                                        height: position.size.height)
                if adjustRect.contains(touchPoint) {
                    return highlight
                }
            }
        }
        return nil
    }
    
    public func displayHighlight() {
        asyncDisplayLayer.displayImmediately()
    }
    
    public override var intrinsicContentSize: CGSize {
        return textNode?.textContentSize ?? .zero
    }
}

extension WLAsyncDisplayLabel: WLAsyncDisplayLayerDelegate {
    
    func asyncDisplayLayerWillDisplay(layer: WLAsyncDisplayLayer) {
        textNode?.textLayout?.removeAttachments()
    }
    
    func asyncDisplayLayer(layer: WLAsyncDisplayLayer?, didDisplayAt context: CGContext, size: CGSize, isCancelld: WLAsyncDisplayIsCanclledBlock) {
        
        // 绘制文字内容
        if let textNode = self.textNode {
            textNode.textLayout?.drawInContext(context: context, point: textNode.frame.origin, containerView: self, isCancelld: isCancelld)
        }
    }
    
    func asyncDisplayLayer(layer: WLAsyncDisplayLayer?, didFinishDisplay finished: Bool) {
        if !finished {
            textNode?.textLayout?.removeAttachments()
        }
    }
    
}

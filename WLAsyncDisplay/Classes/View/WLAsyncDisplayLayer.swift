//
//  WLAsyncDisplayLayer.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/2.
//

import UIKit

typealias WLAsyncDisplayIsCanclled = () -> (Bool)

fileprivate let displayQueue = DispatchQueue(label: "com.WLAsyncDisplay.WLAsyncDisplayLayer.DisplayQueue")

class WLAsyncDisplayLayer: CALayer {
    
    // 是否异步绘制，默认是true
    var displaysAsynchronously = true
    
    // 自增标识类，用于取消绘制
    var displayFlag = WLFlag()
    
    var textNode: WLTextNode?
    
    weak var contentView: UIView?
    
    override init(layer: Any) {
        super.init(layer: layer)
        self.isOpaque = true
    }
    
    override init() {
        super.init()
        self.isOpaque = true
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        cancelAsyncDisplay()
    }
    
    override func display() {
        super.display()
        super.contents = super.contents
        display(asynchronously: displaysAsynchronously)
    }
    
    // 在主线程立即绘制
    func displayImmediately() {
        displayFlag.increment()
        self.display(asynchronously: false)
    }
    
    // 取消异步绘制
    func cancelAsyncDisplay() {
        displayFlag.increment()
    }
    
    func display(asynchronously: Bool) {
        contents = nil
        textNode?.textLayout?.removeAttachments()
        
        if bounds.size.width < 1 || bounds.size.height < 1 { return }
        
        let size = self.bounds.size
        let isOpaque = self.isOpaque
        let contentsScale = self.contentsScale
        
        var backgroundColor = UIColor.white.cgColor
        if let background = self.backgroundColor, background.alpha >= 1 {
            backgroundColor = background
        }
        
        let contextRect = CGRect(origin: .zero, size: CGSize(width: size.width * contentsScale, height: size.height * contentsScale))
        
        if asynchronously {
            let value = displayFlag.value
            let isCancelledBlock: WLAsyncDisplayIsCanclled = { [weak self] in
                return value != self?.displayFlag.value
            }
            
            displayQueue.async { [weak self] in
                UIGraphicsBeginImageContextWithOptions(size, isOpaque, contentsScale)
                guard let context = UIGraphicsGetCurrentContext() else {
                    UIGraphicsEndImageContext()
                    return
                }
                
                if isOpaque {
                    context.saveGState()
                    context.setFillColor(backgroundColor)
                    context.addRect(contextRect)
                    context.fillPath()
                    context.restoreGState()
                }
                
                self?.textNode?.textLayout?.drawInContext(context: context, point: .zero, containerView: self?.contentView, isCancelld: isCancelledBlock)
                
                if isCancelledBlock() {
                    UIGraphicsEndImageContext()
                    self?.textNode?.textLayout?.removeAttachments()
                    return
                }
               
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                DispatchQueue.main.sync { [weak self] in
                    self?.contents = image?.cgImage
                }
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(size, isOpaque, contentsScale)
            guard let context = UIGraphicsGetCurrentContext() else {
                UIGraphicsEndImageContext()
                return
            }
            
            if isOpaque {
                context.saveGState()
                context.setFillColor(backgroundColor)
                context.addRect(contextRect)
                context.fillPath()
                context.restoreGState()
            }
            
            textNode?.textLayout?.drawInContext(context: context, point: .zero, containerView: self.contentView, isCancelld: { false })
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            contents = image?.cgImage
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

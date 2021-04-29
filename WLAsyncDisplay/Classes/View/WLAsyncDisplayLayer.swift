//
//  WLAsyncDisplayLayer.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/2.
//

import UIKit

typealias WLAsyncDisplayIsCanclledBlock = () -> (Bool)

// 异步绘制任务代理
protocol WLAsyncDisplayLayerDelegate: class {
    // 即将要开始绘制
    func asyncDisplayLayerWillDisplay(layer: WLAsyncDisplayLayer)
    // 绘制的具体实现
    func asyncDisplayLayer(layer: WLAsyncDisplayLayer?, didDisplayAt context: CGContext, size: CGSize, isCancelld: WLAsyncDisplayIsCanclledBlock)
    // 绘制已完成
    func asyncDisplayLayer(layer: WLAsyncDisplayLayer?, didFinishDisplay finished: Bool)
}

class WLAsyncDisplayLayer: CALayer {
    
    static let displayQueue: DispatchQueue = {
        let displayQueue = DispatchQueue(label: "com.Gallop.LWAsyncDisplayLayer.displayQueue")
        return displayQueue
    }()
    
    // 是否异步绘制，默认是true
    var displaysAsynchronously = true
    // 自增标识类，用于取消绘制
    var displayFlag = WLFlag()
    
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
        guard let delegate = self.delegate as? WLAsyncDisplayLayerDelegate else {
            return
        }
        
        contents = nil
        
        if asynchronously {
            delegate.asyncDisplayLayerWillDisplay(layer: self)
            
            // 自增取消标志位
            let displayFlag = self.displayFlag
            let value = displayFlag.value
            let isCancelledBlock: WLAsyncDisplayIsCanclledBlock = {
                return value != displayFlag.value
            }
            
            let size = bounds.size
            let opaque = isOpaque
            let scale = contentsScale
            var backgroundColor: CGColor = UIColor.white.cgColor
            if let background = self.backgroundColor,
               background.alpha >= 1 {
                backgroundColor = background
            }
            
            // 不满足绘制条件
            if size.width < 1 || size.height < 1 {
                self.contents = nil
                delegate.asyncDisplayLayer(layer: self, didFinishDisplay: true)
                return
            }
            
            WLAsyncDisplayLayer.displayQueue.async { [weak self] in
                if isCancelledBlock() {
                    return
                }
                
                // 创建content
                UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
                guard let context = UIGraphicsGetCurrentContext() else { return }
                
                if opaque {
                    context.saveGState()
                    context.setFillColor(backgroundColor)
                    context.addRect(CGRect(x: 0, y: 0, width: size.width * scale, height: size.height * scale))
                    context.fillPath()
                    context.restoreGState()
                }
                
                // 通知代理绘制文字
                delegate.asyncDisplayLayer(layer: self, didDisplayAt: context, size: size, isCancelld: isCancelledBlock)
                
                if isCancelledBlock() {
                    UIGraphicsEndImageContext()
                    delegate.asyncDisplayLayer(layer: self, didFinishDisplay: false)
                    return
                }
               
                // 获取绘制contents
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                // 暂时不使用RunLoop进行主线程绘制
                DispatchQueue.main.sync { [weak self] in
                    self?.contents = image?.cgImage
                }
                
            }
            
        } else {
            delegate.asyncDisplayLayerWillDisplay(layer: self)
            
            let size = self.bounds.size
            UIGraphicsBeginImageContextWithOptions(size, isOpaque, contentsScale)
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            var backgroundColor: CGColor = UIColor.white.cgColor
            if let background = self.backgroundColor,
               background.alpha >= 1 {
                backgroundColor = background
            }
            
            if self.isOpaque {
                context.saveGState()
                context.setFillColor(backgroundColor)
                context.addRect(CGRect(x: 0, y: 0, width: size.width * contentsScale, height: size.height * contentsScale))
                context.fillPath()
                context.restoreGState()
            }
            
            // 通知代理绘制文字
            delegate.asyncDisplayLayer(layer: self, didDisplayAt: context, size: size, isCancelld: { false })
            
            // 获取绘制contents
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.contents = image?.cgImage
            delegate.asyncDisplayLayer(layer: self, didFinishDisplay: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

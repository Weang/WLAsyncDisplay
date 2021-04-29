//
//  WLTextAttachment.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/4.
//

import UIKit

public protocol WLTextAttachmentProtocol: class {
    func drawAttachments(on view: UIView, context: CGContext, frame: CGRect)
    func removeAttachments()
}

extension UIImage: WLTextAttachmentProtocol {
    
    public func drawAttachments(on view: UIView, context: CGContext, frame: CGRect) {
        guard let image = self.cgImage else {
            return
        }
        context.saveGState()
        context.translateBy(x: 0, y: frame.maxY + frame.minY)
        context.scaleBy(x: 1, y: -1)
        context.draw(image, in: frame)
        context.restoreGState()
    }
    
    public func removeAttachments() {
        
    }
    
}

extension UIView: WLTextAttachmentProtocol {
    
    public func drawAttachments(on view: UIView, context: CGContext, frame: CGRect) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.frame = frame
            view.addSubview(self)
        }
    }
    
    public func removeAttachments() {
        DispatchQueue.main.async { [weak self] in
            self?.removeFromSuperview()
        }
    }
    
}

extension CALayer: WLTextAttachmentProtocol {
    
    public func drawAttachments(on view: UIView, context: CGContext, frame: CGRect) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.frame = frame
            view.layer.addSublayer(self)
        }
    }
    
    public func removeAttachments() {
        DispatchQueue.main.async { [weak self] in
            self?.removeFromSuperlayer()
        }
    }
}

// 附件信息，可以显示任何遵守WLTextAttachmentProtocol的类
class WLTextAttachment: NSObject {

    let contents: WLTextAttachmentProtocol
    
    var contentEdgeInsets = UIEdgeInsets.zero
    
    init(contents: WLTextAttachmentProtocol) {
        self.contents = contents
    }
    
}

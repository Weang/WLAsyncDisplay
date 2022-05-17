//
//  WLTextAttachmentType.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2022/5/16.
//

import UIKit

public protocol WLTextAttachmentType: AnyObject {
    func drawAttachments(on view: UIView?, context: CGContext, frame: CGRect)
    func removeAttachments()
}

extension UIImage: WLTextAttachmentType {
    
    public func drawAttachments(on view: UIView?, context: CGContext, frame: CGRect) {
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

extension UIView: WLTextAttachmentType {
    
    public func drawAttachments(on view: UIView?, context: CGContext, frame: CGRect) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.frame = frame
            view?.addSubview(self)
        }
    }
    
    public func removeAttachments() {
        DispatchQueue.main.async { [weak self] in
            self?.removeFromSuperview()
        }
    }
    
}

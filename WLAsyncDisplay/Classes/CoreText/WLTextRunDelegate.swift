//
//  WLTextRunDelegate.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/4.
//

import UIKit

// CTRunDelegate封装
class WLTextRunDelegate: NSObject {

    // 上行距
    var ascent: CGFloat = 0.0
    // 下行距
    var descent: CGFloat = 0.0
    // 宽度
    var width: CGFloat = 0.0
    // 高度
    var height: CGFloat = 0.0
 
    var runDelegate: CTRunDelegate? {
        let extentBuffer = UnsafeMutablePointer<WLTextRunDelegate>.allocate(capacity: 1)
        extentBuffer.initialize(to: self)
        
        var callBacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1) { (_) in
            
        } getAscent: { (ref) -> CGFloat in
            return ref.assumingMemoryBound(to: WLTextRunDelegate.self).pointee.ascent
        } getDescent: { (ref) -> CGFloat in
            return ref.assumingMemoryBound(to: WLTextRunDelegate.self).pointee.descent
        } getWidth: { (ref) -> CGFloat in
            return ref.assumingMemoryBound(to: WLTextRunDelegate.self).pointee.width
        }

        return CTRunDelegateCreate(&callBacks, extentBuffer)
    }

    
}

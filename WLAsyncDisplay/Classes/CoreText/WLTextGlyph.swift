//
//  WLTextGlyph.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/2.
//

import UIKit

class WLTextGlyph: NSObject {

    // 字符信息
    var glyph: CGGlyph
    
    // 字符位置起点
    var position: CGPoint = .zero
    
    // 上行高度
    var ascent: CGFloat = 0
    
    // 下行高度（负值）
    var descent: CGFloat = 0
    
    // 上行字符的 descent 到下行的 ascent 之间的距离
    var leading: CGFloat = 0
    
    // 字符宽度
    var width: CGFloat = 0
    
    // 字符高度
    var height: CGFloat = 0
    
    init(glyph: CGGlyph) {
        self.glyph = glyph
    }
    
}

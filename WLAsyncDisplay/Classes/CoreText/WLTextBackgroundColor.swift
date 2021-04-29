//
//  WLTextBackgroundColor.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/7.
//

import UIKit

class WLTextBackgroundColor: NSObject {
    // 文字range
    var range: NSRange = NSRange(location: 0, length: 0)
    // 文字背景颜色
    var backgroundColor: UIColor = .white
    // 文字range在CTFrame中的所有位置
    var positions: [CGRect] = []
    
    var cornerRadius: CGFloat = 2
}

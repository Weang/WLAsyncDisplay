//
//  WLTextHighlight.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/7.
//

import UIKit

public class WLTextHighlight: NSObject {
    
    // 文字range
    var range: NSRange = NSRange(location: 0, length: 0)
    // 高亮文字颜色
    var linkColor: UIColor = .black
    // 文字点击背景颜色
    var hightlightColor: UIColor = .black
    // 文字range在CTFrame中的所有位置
    var positions: [CGRect] = []
    
    var userInfo: [String: Any]? = nil
    
}

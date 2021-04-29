//
//  WLTextContainer.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/2.
//

import UIKit

// 文本容器，表示文字在创建时的大小，不表示文字的实际显示大小
class WLTextContainer: NSObject {

    // 容器大小
    let size: CGSize
    // 边缘大小
    let edgeInsets: UIEdgeInsets
    // 容器路径
    let path: UIBezierPath
    // 最大行数限制
    var maxNumberOfLines: Int = 0
    
    init(containerSize: CGSize, edgeInsets: UIEdgeInsets = .zero) {
        self.size = containerSize
        self.edgeInsets = edgeInsets
        
        var rect = CGRect(origin: .zero, size: containerSize)
        rect = rect.inset(by: edgeInsets)
        self.path = UIBezierPath.init(rect: rect)
    }
    
}

//
//  WLTruncationToken.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/14.
//

import UIKit

public class WLTruncationToken: NSObject {
    
    let attributedString: NSMutableAttributedString
    
    // 是否可点击
    public var isEnabled: Bool = true
    
    // 点击文字颜色
    public var linkColor: UIColor = .blue
    
    // 点击高亮颜色
    public var highlightColor: UIColor = .lightGray
    
    public init(string: String) {
        self.attributedString = NSMutableAttributedString(string: string)
        super.init()
    }
    
}

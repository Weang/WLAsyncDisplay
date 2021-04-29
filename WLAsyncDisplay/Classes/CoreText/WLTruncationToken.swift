//
//  WLTruncationToken.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/14.
//

import UIKit

public class WLTruncationToken: NSObject {

    static let highlightKey = "WLTruncationTokenHighlightKey"
    
    let attributedString: NSMutableAttributedString
    
    public var isEnabled: Bool = true
    public var highlightColor: UIColor = .lightGray
    
    public init(attributedString: NSMutableAttributedString) {
        self.attributedString = attributedString
        super.init()
    }
    
}

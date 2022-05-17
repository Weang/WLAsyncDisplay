//
//  WLNSAttributedStringKeys.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/4.
//

import UIKit

struct WLAttributedStringKey {
    
    static let attachment = NSAttributedString.Key(rawValue: "WLNSAttributedStringKeyAttachment")
    
    static let link = NSAttributedString.Key(rawValue: "WLNSAttributedStringKeyLink")
    
    static let backgroundColor = NSAttributedString.Key(rawValue: "WLNSAttributedStringKeyBackgroundColor")
    
    static let truncationToken = NSAttributedString.Key(rawValue: "WLNSAttributedStringKeyTruncationToken")
    
    static let regularExpression = NSAttributedString.Key(rawValue: "WLNSAttributedStringKeyRegularExpression")
    
}

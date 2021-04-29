//
//  WLRegularExpression.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/16.
//

import UIKit

public struct WLRegularExpression {
    
    public enum RegularType: String {
        case topic = "WLRegularExpressionTopic"
        case tel = "WLRegularExpressionTel"
        case url = "WLRegularExpressionUrl"
        case at = "WLRegularExpressionAt"
    }
    
    static let topicRegular = "#[^#]+#"
    static let telRegular = "1[3|4|5|7|8][0-9]\\d{8}"
    static let urlRegular = "[a-zA-z]+://[^\\s]*"
    static let atRegular = "@[-_a-zA-Z0-9\u{4E00}-\u{9FA5}\\.]+"
    static let emojiRegular = "\\[[^ \\[\\]]+?\\]"
    
    static let topicRegularExpression = try? NSRegularExpression.init(pattern: topicRegular, options: .anchorsMatchLines)
    static let telRegularExpression = try? NSRegularExpression.init(pattern: telRegular, options: .anchorsMatchLines)
    static let urlRegularExpression = try? NSRegularExpression.init(pattern: urlRegular, options: .anchorsMatchLines)
    static let atRegularExpression = try? NSRegularExpression.init(pattern: atRegular, options: .anchorsMatchLines)
    static let emojiRegularExpression = try? NSRegularExpression.init(pattern: emojiRegular, options: .anchorsMatchLines)
    
    static func parseWith(type: RegularType, textNode: WLTextNode, linkColor: UIColor, highlightColor: UIColor) {
        let regularExpression: NSRegularExpression?
        switch type {
        case .topic:
            regularExpression = topicRegularExpression
        case .tel:
            regularExpression = telRegularExpression
        case .url:
            regularExpression = urlRegularExpression
        case .at:
            regularExpression = atRegularExpression
        }
        guard let text = textNode.text,
              let expression = regularExpression else {
            return
        }
        let resultArray = expression.matches(in: text,
                                             options: .init(rawValue: 0),
                                             range: NSRange(location: 0, length: text.count))
        for result in resultArray {
            let range = result.range
            let content = (text as NSString).substring(with: range)
            if text.count >= range.location + range.length {
                textNode.addLinkAt(range: range,
                                   linkColor: linkColor,
                                   highLightColor: highlightColor,
                                   userInfo: [type.rawValue: content])
            }
        }
    }
    
    static func parseEmojiWith(textNode: WLTextNode, imageClosure: (String) -> UIImage?) {
        guard let text = textNode.text,
              let expression = emojiRegularExpression else {
            return
        }
        let resultArray = expression.matches(in: text,
                                             options: .init(rawValue: 0),
                                             range: NSRange(location: 0, length: text.count))
        for (index, result) in resultArray.enumerated() {
            var range = result.range
            let frontEmojiLength = (0..<index).map{ resultArray[$0] }.map{ $0.range.length - 1 }.reduce(0, +)
            let content = (text as NSString).substring(with: range)
            if text.count >= range.location + range.length,
               let image = imageClosure(content) {
                range.location -= frontEmojiLength
                textNode.replaceTextWithAttachment(contents: image, size: CGSize(width: 13, height: 13), range: range)
            }
        }
    }
    
}

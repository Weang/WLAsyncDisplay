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
    
    public static var topicRegular = "#[^#]+#"
    public static var telRegular = "1[3|4|5|7|8][0-9]\\d{8}|\\d{3,4}-\\d{7,8}"
    public static var urlRegular = "[a-zA-z]+://[^\\s]*"
    public static var atRegular = "@[-_a-zA-Z0-9\u{4E00}-\u{9FA5}\\.]+"
    public static var emojiRegular = "\\[[^ \\[\\]]+?\\]"
    
    public static func parseWith(type: RegularType, textNode: WLTextNode, linkColor: UIColor, highlightColor: UIColor) {
        let regularExpression: NSRegularExpression?
        switch type {
        case .topic:
            regularExpression = try? NSRegularExpression(pattern: topicRegular, options: .anchorsMatchLines)
        case .tel:
            regularExpression = try? NSRegularExpression(pattern: telRegular, options: .anchorsMatchLines)
        case .url:
            regularExpression = try? NSRegularExpression(pattern: urlRegular, options: .anchorsMatchLines)
        case .at:
            regularExpression = try? NSRegularExpression(pattern: atRegular, options: .anchorsMatchLines)
        }
        guard let text = textNode.text, let expression = regularExpression else {
            return
        }
        let resultArray = expression.matches(in: text, options: .init(rawValue: 0), range: NSRange(location: 0, length: text.count))
        for result in resultArray {
            let range = result.range
            let content = (text as NSString).substring(with: range)
            if text.count >= range.location + range.length {
                let userInfo: [String: Any] = ["type": type.rawValue,
                                               "content": content,
                                               WLAttributedStringKey.regularExpression.rawValue: true]
                textNode.addLinkAt(range: range, linkColor: linkColor, highLightColor: highlightColor, userInfo: userInfo)
            }
        }
    }
    
    public static func parseEmojiWith(textNode: WLTextNode, size: CGSize, imageClosure: (String) -> UIImage?) {
        guard let text = textNode.text,
              let expression = try? NSRegularExpression(pattern: emojiRegular, options: .anchorsMatchLines) else {
            return
        }
        let resultArray = expression.matches(in: text, options: .init(rawValue: 0), range: NSRange(location: 0, length: text.count))
        for (index, result) in resultArray.enumerated() {
            var range = result.range
            let frontEmojiLength = (0..<index).map{ resultArray[$0] }.map{ $0.range.length - 1 }.reduce(0, +)
            let content = (text as NSString).substring(with: range)
            if text.count >= range.location + range.length,
               let image = imageClosure(content) {
                range.location -= frontEmojiLength
                textNode.replaceTextWithAttachment(attachment: image, size: size, range: range)
            }
        }
    }
    
}

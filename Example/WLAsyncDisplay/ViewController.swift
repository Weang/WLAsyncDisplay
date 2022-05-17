//
//  ViewController.swift
//  WLAsyncDisplay
//

import UIKit
import WLAsyncDisplay

class ViewController: UIViewController {
    
    let node = WLTextNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        node.width = 300
        node.text = "iOS是由苹果公司开发的移动操作系统。苹果公司最早于2007年1月9日的Macworld大会上公布这个系统，最初是设计给iPhone使用的，后来陆续套用到iPod touch、iPad上。iOS与苹果的macOS操作系统一样，属于类Unix的商业操作系统。"
        node.lineBreakMode = .byCharWrapping
        node.lineSpacing = 6
        node.maxNumberOfLines = 5
        node.truncationToken = WLTruncationToken(string: "展开...")
        let color = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        node.addBackgroundColorAt(range: NSRange(location: 3, length: 12), backgroundColor: color, cornerRadius: 0)
        node.addLinkAt(range: NSRange(location: 34, length: 7), linkColor: color, underlineStyle: .styleSingle, highLightColor: .darkGray)
        
        let label = WLAsyncDisplayLabel()
        label.delegate = self
        label.backgroundColor = UIColor(white: 0.9, alpha: 1)
        view.addSubview(label)
        label.textNode = node
        label.frame = CGRect(origin: CGPoint(x: 40, y: 90), size: node.textSuggestSize)
    }
    
}
extension ViewController: WLAsyncDisplayLabelDelegate {
  
    func asyncDisplayLabelDidClickAtTruncation(_ label: WLAsyncDisplayLabel) {
        node.maxNumberOfLines = 0
        label.textNode = node
        label.frame = CGRect(origin: CGPoint(x: 40, y: 90), size: node.textSuggestSize)
        label.displayImmediately()
    }
    
    func asyncDisplayLabel(_ label: WLAsyncDisplayLabel, didClickAtRegularExpression type: WLRegularExpression.RegularType, content: String) {
        print(content)
    }
    
}

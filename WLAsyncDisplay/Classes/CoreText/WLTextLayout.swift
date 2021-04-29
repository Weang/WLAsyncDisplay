//
//  WLTextLayout.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/2.
//

import UIKit

public class WLTextLayout: NSObject {
    
    let container: WLTextContainer
    let attributedString: NSAttributedString
    
    // 文本边框容器大小，不是实际文字大小
    var cgPathBox = CGRect.zero
    
    var ctFrame: CTFrame?
    
    // 通过CoreText方法计算出的建议的绘制大小
    var suggestSize: CGSize = .zero
    // 包含每个CTLint的最小的位置信息，就是实际的绘制大小
    var textBoundingRect: CGRect = .zero
    var textBoundingSize: CGSize = .zero
    
    // 是否折叠
    var needTruncation = false
    
    // CTLine数组
    var linesArray: [WLTextLine] = []
    
    // 附件信息，包括附件模型、附件索引和附件位置
    var attachments: [WLTextAttachment] = []
    var attachmentRanges: [NSRange] = []
    var attachmentRects: [CGRect] = []
    
    // 点击高亮信息
    var textHighlights: [WLTextHighlight] = []
    
    // 高亮显示控制
    var highlight: WLTextHighlight?
    var highlightNodeOrgin: CGPoint = .zero
    
    // 背景颜色
    var backgroundColors: [WLTextBackgroundColor] = []
    
    // 结尾断点符号
    var truncationToken: WLTruncationToken? = nil {
        didSet {
            createTruncationToken()
        }
    }
    
    var isDebug: Bool = false
    
    init?(container: WLTextContainer, attributedString: NSAttributedString?) {
        guard let attributedString = attributedString else {
            return nil
        }
        self.container = container
        self.attributedString = attributedString
        super.init()
        createTextLayout()
    }
    
    private func createTextLayout() {
        let mutableAtrributedString = NSMutableAttributedString.init(attributedString: attributedString)
        let containerPath = container.path.cgPath
        let containerBoudingBox = containerPath.boundingBoxOfPath
        let originLength = mutableAtrributedString.length
        var cfRange = CFRange(location: 0, length: originLength)
        
        // 计算显示文字大小区域
        let ctFrameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let suggestSize = getSuggetSizeAndRange(framesetter: ctFrameSetter,
                                                attributedString: mutableAtrributedString,
                                                size: containerBoudingBox.size,
                                                numberOfLines: container.maxNumberOfLines,
                                                rangeToSize: &cfRange)
        
        let realLength = cfRange.length
        
        let suggestPath = CGMutablePath()
        var suggestRect = CGRect(x: containerBoudingBox.origin.x,
                                 y: containerBoudingBox.origin.y,
                                 width: containerBoudingBox.size.width,
                                 height: suggestSize.height)
        suggestPath.addRect(suggestRect)
        
        // 最终显示的文字排版
        let ctFrame = CTFramesetterCreateFrame(ctFrameSetter, cfRange, suggestPath, nil)
        let ctLines = CTFrameGetLines(ctFrame)
        let lineCount = CFArrayGetCount(ctLines)
        var lineOrigins: UnsafeMutablePointer<CGPoint>?
        if lineCount > 0 {
            let lineOriginsArray = UnsafeMutablePointer<CGPoint>.allocate(capacity: lineCount)
            // 获取每行文字的起点，CoreText中，起点为左下角
            CTFrameGetLineOrigins(ctFrame, CFRange(location: 0, length: lineCount), lineOriginsArray)
            lineOrigins = lineOriginsArray
        }
        
        var textBoundingRect = CGRect.zero
        
        var lines: [WLTextLine] = []
        
        for i in 0..<lineCount {
            let ctLine = unsafeBitCast(CFArrayGetValueAtIndex(ctLines, i), to: CTLine.self)
            // 分别获取每个CTRun的属性
            let ctRuns = CTLineGetGlyphRuns(ctLine)
            let runCount = CFArrayGetCount(ctRuns)
            if runCount == 0 { continue }
            for j in 0..<runCount {
                // CTRun是富文本单行中以富文本key分割的最小单位，同一个run中的所有字符的富文本属性是相同的
                let run = unsafeBitCast(CFArrayGetValueAtIndex(ctRuns, j), to: CTRun.self)
                if CTRunGetGlyphCount(run) == 0 {
                    continue
                }
                let attributes = CTRunGetAttributes(run) as NSDictionary
                // 获取点击高亮位置
                if let highlight = attributes.value(forKey: WLAttributedStringKey.link.rawValue) as? WLTextHighlight {
                    let highlightPositions = self.positionsWith(ctFrame: ctFrame, range: highlight.range)
                    highlight.positions = highlightPositions
                    self.textHighlights.append(highlight)
                }
                // 获取背景颜色位置
                if let backgroundColor = attributes.value(forKey: WLAttributedStringKey.backgroundColor.rawValue) as? WLTextBackgroundColor {
                    let positions = self.positionsWith(ctFrame: ctFrame, range: backgroundColor.range)
                    backgroundColor.positions = positions
                    self.backgroundColors.append(backgroundColor)
                }
            }
            
            // lines在文字边框中相对的UIKit坐标系的起点
            let ctLineOrigin = lineOrigins?[i] ?? .zero
            let position = CGPoint(x: suggestRect.origin.x + ctLineOrigin.x,
                                   y: suggestRect.size.height - ctLineOrigin.y)
            // 封装CTLine
            let line = WLTextLine.init(cTLine: ctLine, lineOrigin: position)
            line.ctLineOrigin = ctLineOrigin
            line.index = i
            line.row = i
            if i == 0 {
                textBoundingRect = line.frame
            } else {
                textBoundingRect = textBoundingRect.union(line.frame)
            }
            lines.append(line)
            
            self.attachments.append(contentsOf: line.attachments)
            self.attachmentRanges.append(contentsOf: line.attachmentRanges)
            self.attachmentRects.append(contentsOf: line.attachmentRects)
        }
        
        suggestRect = CGRect(x: suggestRect.origin.x - container.edgeInsets.left,
                             y: suggestRect.origin.y - container.edgeInsets.top,
                             width: suggestRect.size.width + container.edgeInsets.left + container.edgeInsets.right,
                             height: suggestRect.size.height + container.edgeInsets.top + container.edgeInsets.bottom)
        
        self.ctFrame = ctFrame
        self.suggestSize = suggestSize
        self.textBoundingRect = textBoundingRect
        self.textBoundingSize = textBoundingRect.size
        self.linesArray = lines
        self.cgPathBox = containerBoudingBox
        self.needTruncation = originLength != realLength
    }
    
    /// 根据CTFramesetter和给定的宽度和最大行数，获取文字显示区域大小
    /// - Parameters:
    ///   - size: 文字边框的大小，固定宽度
    ///   - numberOfLines: 最大行数限制
    ///   - rangeToSize: attributedString的位置信息，并且修改为真实显示的位置信息
    /// - Returns: 文字区域大小
    func getSuggetSizeAndRange(framesetter: CTFramesetter,
                               attributedString: NSAttributedString,
                               size: CGSize,
                               numberOfLines: Int,
                               rangeToSize: inout CFRange) -> CGSize {
        let constraints = CGSize(width: size.width, height: CGFloat(MAXFLOAT))
        if numberOfLines > 0 { // 限制行数，根据实际显示的行数计算文字大小
            let path = CGMutablePath()
            path.addRect(CGRect(origin: .zero, size: constraints))
            
            let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
            let lines = CTFrameGetLines(frame)
            let lineCount = CFArrayGetCount(lines)
            if lineCount > 0 {
                // 获取在最大行数限制下显示的最大行数的index
                let lastVisibleLineIndex = min(numberOfLines, lineCount) - 1
                let lastVisibleLine = unsafeBitCast(CFArrayGetValueAtIndex(lines, lastVisibleLineIndex), to: CTLine.self)
                // 获取显示的最大长度的文字位置和长度
                let visibleRange = CTLineGetStringRange(lastVisibleLine)
                rangeToSize = CFRange(location: 0, length: visibleRange.location + visibleRange.length)
            }
        }
        let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                                         rangeToSize,
                                                                         nil,
                                                                         constraints,
                                                                         nil)
        return CGSize(width: ceil(suggestedSize.width), height: ceil(suggestedSize.height))
    }
    
    // 获取指定的range在CTFrame中的位置
    private func positionsWith(ctFrame: CTFrame, range: NSRange) -> [CGRect] {
        var positions: [CGRect] = []
        
        let boundsRect = CTFrameGetPath(ctFrame).boundingBoxOfPath
        let lines = CTFrameGetLines(ctFrame)
        let lineCount = CFArrayGetCount(lines)
        if lineCount == 0 {
            return positions
        }
        
        let startPosition = range.location
        let endPosition = NSMaxRange(range)
        
        let transform = CGAffineTransform.init(translationX: 0, y: boundsRect.size.height).scaledBy(x: 1, y: -1)
        
        // 获取每行文字的起点，CoreText中，起点为左下角
        let origins = UnsafeMutablePointer<CGPoint>.allocate(capacity: lineCount)
        CTFrameGetLineOrigins(ctFrame, CFRange(location: 0, length: 0), origins)
        
        // 遍历每个CTLine
        for i in 0..<lineCount {
            let lineOrigin = origins[i]
            let line = unsafeBitCast(CFArrayGetValueAtIndex(lines, i), to: CTLine.self)
            // 当前line在文字中的range，需要判断是否和高亮range有交集
            let range = CTLineGetStringRange(line)
            // 高亮range是否在本行开始
            let isStartAtRange = isPosition(startPosition, in: range)
            // 高亮range是否在本行结束
            let isEndAtRange = isPosition(endPosition, in: range)
            
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            let width = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
            
            // 开始和结束的index的字符到原点的x距离
            let startOffset = CTLineGetOffsetForStringIndex(line, startPosition, nil)
            let endOffset = CTLineGetOffsetForStringIndex(line, endPosition, nil)
            
            var lineRect: CGRect?
            
            // ###: CTFrame  ___: 高亮range
            if isStartAtRange && isEndAtRange {
                /*
                 *       ####################
                 line i  ###_____________####
                 *       ####################
                 */
                lineRect = CGRect(x: lineOrigin.x + startOffset,
                                  y: lineOrigin.y - descent,
                                  width: endOffset - startOffset,
                                  height: ascent + descent)
            } else {
                if isStartAtRange {
                    /*
                     *       ####################
                     line i  ###_________________
                     *       ______##############
                     */
                    lineRect = CGRect(x: lineOrigin.x + startOffset,
                                      y: lineOrigin.y - descent,
                                      width: width - startOffset,
                                      height: ascent + descent)
                } else if startPosition < range.location &&
                            endPosition >= range.location + range.length {
                    /*
                     *       ##############______
                     line i  ____________________
                     *       ___#################
                     */
                    lineRect = CGRect(x: lineOrigin.x,
                                      y: lineOrigin.y - descent,
                                      width: width,
                                      height: ascent + descent)
                } else if startPosition < range.location && isEndAtRange {
                    /*
                     *       ##############______
                     line i  ______________######
                     *       ####################
                     */
                    lineRect = CGRect(x: lineOrigin.x,
                                      y: lineOrigin.y - descent,
                                      width: endOffset,
                                      height: ascent + descent)
                }
            }
            
            if let lineRect = lineRect {
                let realRect = lineRect.applying(transform)
                let adjustRect = CGRect(x: realRect.origin.x + boundsRect.origin.x,
                                        y: realRect.origin.y + boundsRect.origin.y,
                                        width: realRect.width,
                                        height: realRect.height)
                positions.append(adjustRect)
            }
        }
        
        return positions
    }
    
    // 判断位置是是否在range的location和length之间
    private func isPosition(_ position: Int, in range: CFRange) -> Bool {
        return position >= range.location && position < range.location + range.length
    }
    
    // 添加结尾断点符
    func createTruncationToken() {
        guard needTruncation,
              let lastLine = linesArray.last else { return }
        
        let truncationToken: NSMutableAttributedString
        
        if let customTruncationToken = self.truncationToken {
            truncationToken = customTruncationToken.attributedString
        } else {
            // 默认 ... 结尾符号
            truncationToken = NSMutableAttributedString.init(string: "\u{2026}")
            
            typealias Key = NSAttributedString.Key
            var attributes: [Key: Any] = [.foregroundColor: UIColor.black,
                                          .font: UIFont.systemFont(ofSize: 15)]
            let runs = CTLineGetGlyphRuns(lastLine.cTLine)
            let runCount = CFArrayGetCount(runs)
            if runCount > 0 {
                let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, CFArrayGetCount(runs) - 1), to: CTRun.self)
                let runAttributes = CTRunGetAttributes(run) as NSDictionary
                if let foregroundColor = runAttributes.value(forKey: Key.foregroundColor.rawValue) as? UIColor {
                    attributes[.foregroundColor] = foregroundColor
                }
                if let font = runAttributes.value(forKey: Key.font.rawValue) as? UIFont {
                    attributes[.font] = font
                }
            }
            if let range = truncationToken.string.range(of: truncationToken.string)  {
                truncationToken.addAttributes(attributes, range: NSRange.init(range, in: truncationToken.string))
            }
        }
        
        // 将结尾符号拼接到最后一行line
        let truncationTokenLine = CTLineCreateWithAttributedString(truncationToken)
        let lastLineText = NSMutableAttributedString.init(attributedString: attributedString.attributedSubstring(from: lastLine.range))
        lastLineText.append(truncationToken)
        let ctLastLineExtend = CTLineCreateWithAttributedString(lastLineText)
        let truncatedWidth = cgPathBox.width
        guard let ctTruncatedLine = CTLineCreateTruncatedLine(ctLastLineExtend, Double(truncatedWidth), .end, truncationTokenLine) else {
            return
        }
        let truncatedLineRange = CTLineGetStringRange(ctTruncatedLine)
        let truncatedLineWidth = CTLineGetOffsetForStringIndex(ctTruncatedLine, truncatedLineRange.length, nil)
        
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        let truncationTokenLineWidth = CGFloat(CTLineGetTypographicBounds(truncationTokenLine, &ascent, &descent, nil))
        
        // 给结尾符号添加点击事件
        if let truncationToken = self.truncationToken,
           truncationToken.isEnabled {
            let highlight = WLTextHighlight()
            highlight.hightlightColor = truncationToken.highlightColor
            highlight.userInfo = [WLTruncationToken.highlightKey: true]
            highlight.positions = [CGRect(x: lastLine.lineOrigin.x + (truncatedLineWidth - truncationTokenLineWidth),
                                          y: lastLine.lineOrigin.y - ascent,
                                          width: truncationTokenLineWidth,
                                          height: ascent + descent)]
            self.textHighlights.append(highlight)
        }
        
        let truncatedLine = WLTextLine.init(cTLine: ctTruncatedLine, lineOrigin: lastLine.lineOrigin)
        truncatedLine.index = lastLine.index
        truncatedLine.row = lastLine.row
        
        linesArray.removeLast()
        linesArray.append(truncatedLine)
    }
    
    /// 绘制内容方法
    /// - Parameters:
    ///   - context: 图形上下文
    ///   - point: view在UIKit坐标系中的起点
    func drawInContext(context: CGContext, point: CGPoint, containerView: UIView, isCancelld: WLAsyncDisplayIsCanclledBlock) {
        
        // 背景颜色
        if backgroundColors.count > 0 {
            drawTextBackgroundColorInContext(context: context, point: point, isCancelld: isCancelld)
        }
        
        // 显示高亮
        drawTextHighlight()
        
        // 文字
        drawTextInContext(context: context, point: point, isCancelld: isCancelld)
        
        // 附件
        if self.attachments.count > 0 {
            self.drawAttachmentsInContext(context: context, point: point, containerView: containerView, isCancelld: isCancelld)
        }
        
        if self.isDebug {
            self.drawDebug(context: context, point: point, containerView: containerView, isCancelld: isCancelld)
        }
        
    }
    
    // 绘制文字
    private func drawTextInContext(context: CGContext, point: CGPoint, isCancelld: WLAsyncDisplayIsCanclledBlock) {
        context.saveGState()
        context.translateBy(x: point.x, y: point.y)
        context.translateBy(x: 0, y: 0)
        context.scaleBy(x: 1, y: -1)
        self.linesArray.forEach { (line) in
            if isCancelld() {
                return
            }
            context.textMatrix = .identity
            context.textPosition = CGPoint(x: line.lineOrigin.x, y: -line.lineOrigin.y)
            let runs = CTLineGetGlyphRuns(line.cTLine)
            for j in 0..<CFArrayGetCount(runs) {
                if isCancelld() {
                    return
                }
                let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, j), to: CTRun.self)
                CTRunDraw(run, context, CFRange(location: 0, length: 0))
            }
        }
        context.restoreGState()
    }
    
    // 绘制背景颜色
    private func drawTextBackgroundColorInContext(context: CGContext, point: CGPoint, isCancelld: WLAsyncDisplayIsCanclledBlock) {
        for backgroundColor in backgroundColors {
            if isCancelld() {
                return
            }
            for position in backgroundColor.positions {
                let adjustRect = CGRect(x: point.x + position.origin.x,
                                        y: point.y + position.origin.y,
                                        width: position.width,
                                        height: position.height)
                let beizerPath = UIBezierPath.init(roundedRect: adjustRect,
                                                   cornerRadius: backgroundColor.cornerRadius)
                backgroundColor.backgroundColor.setFill()
                beizerPath.fill()
            }
            
        }
    }
    
    func drawTextHighlight() {
        guard let highlight = self.highlight else {
            return
        }
        for positions in highlight.positions {
            let adjustRect = CGRect(x: positions.origin.x + highlightNodeOrgin.x,
                                    y: positions.origin.y + highlightNodeOrgin.y,
                                    width: positions.size.width,
                                    height: positions.size.height)
            let beizerPath = UIBezierPath.init(rect: adjustRect)
            highlight.hightlightColor.setFill()
            beizerPath.fill()
        }
    }
    
    // 绘制附件信息
    private func drawAttachmentsInContext(context: CGContext, point: CGPoint, containerView: UIView, isCancelld: WLAsyncDisplayIsCanclledBlock) {
        for i in 0..<self.attachments.count {
            if isCancelld() {
                return
            }
            let attachment = attachments[i]
            var rect = attachmentRects[i]
            rect = rect.inset(by: attachment.contentEdgeInsets)
            rect.origin.y += point.y
            rect.origin.x += point.x
            attachment.contents.drawAttachments(on: containerView, context: context, frame: rect)
        }
    }
    
    private func drawDebug(context: CGContext, point: CGPoint, containerView: UIView, isCancelld: WLAsyncDisplayIsCanclledBlock) {
        
        // CTLine显示边框
        let rect = textBoundingRect.offsetBy(dx: point.x, dy: point.y)
        context.addRect(rect)
        context.setLineWidth(0.2)
        context.setStrokeColor(UIColor.red.cgColor)
        context.strokePath()
        
        for line in linesArray {
            if isCancelld() {
                return
            }
            
            // baseline
            context.move(to: CGPoint(x: line.lineOrigin.x + point.x, y: line.lineOrigin.y + point.y))
            context.addLine(to: CGPoint(x: line.lineOrigin.x + point.x + line.lineWidth, y: line.lineOrigin.y + point.y))
            context.setLineWidth(0.2)
            context.setStrokeColor(UIColor.red.cgColor)
            context.strokePath()
            
            // CGGlyph边框
            for glyph in line.glyphs {
                context.addRect(CGRect(x: line.lineOrigin.x + point.x + glyph.position.x,
                                       y: line.lineOrigin.y + point.y - glyph.ascent,
                                       width: glyph.width,
                                       height: glyph.ascent + glyph.descent))
                context.setLineWidth(0.2)
                context.setStrokeColor(UIColor.red.cgColor)
                context.strokePath()
            }
        }
    }
    
    func removeAttachments() {
        for attachment in attachments {
            attachment.contents.removeAttachments()
        }
    }
}

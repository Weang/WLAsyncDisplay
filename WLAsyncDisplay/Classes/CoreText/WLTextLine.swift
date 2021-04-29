//
//  WLTextLine.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/2.
//

import UIKit

class WLTextLine: NSObject {
    
    let cTLine: CTLine
    // 起始位置
    let lineOrigin: CGPoint
    // 在ctFrame中的坐标起点
    var ctLineOrigin: CGPoint = .zero
    // line在UIKit中的坐标系
    var frame: CGRect = .zero
    // line在string中的位置
    var range: NSRange = NSRange(location: 0, length: 0)
    // 行宽
    var lineWidth: CGFloat = 0
    // 上行高度
    var ascent: CGFloat = 0
    // 下行高度（负值）
    var descent: CGFloat = 0
    // 上行字符的 descent 到下行的 ascent 之间的距离
    var leading: CGFloat = 0
    
    // 字符数组
    var glyphs: [WLTextGlyph] = []
    
    // line在lines中的位置
    var index = 0
    // 行数
    var row = 0
    
    // 首个字符的左边空白宽度
    var firstGlyphPosition: CGFloat = 0
    // 尾部空白宽度
    var trailingWhitespaceWidth: CGFloat = 0
    
    // 附件信息，包括附件模型、附件索引和附件位置
    var attachments: [WLTextAttachment] = []
    var attachmentRanges: [NSRange] = []
    var attachmentRects: [CGRect] = []
    
    init(cTLine: CTLine, lineOrigin: CGPoint) {
        self.cTLine = cTLine
        self.lineOrigin = lineOrigin
        super.init()
        
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var leading: CGFloat = 0
        
        self.lineWidth = CGFloat(CTLineGetTypographicBounds(cTLine, &ascent, &descent, &leading))
        self.ascent = ascent
        self.descent = descent
        self.leading = leading
        
        let range = CTLineGetStringRange(cTLine)
        self.range = NSRange(location: range.location, length: range.length)
        
        let glyphsCount = CTLineGetGlyphCount(cTLine)
        
        if glyphsCount > 0 {
            let runs = CTLineGetGlyphRuns(cTLine)
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, 0), to: CTRun.self)
            var position: CGPoint = .zero
            CTRunGetPositions(run, CFRange(location: 0, length: 1), &position)
            firstGlyphPosition = position.x
        }
        trailingWhitespaceWidth = CGFloat(CTLineGetTrailingWhitespaceWidth(cTLine))
        
        // 计算实际line在UIKit坐标系的frame
        frame = CGRect(x: lineOrigin.x + firstGlyphPosition,
                       y: lineOrigin.y - ascent,
                       width: lineWidth,
                       height: ascent + descent)
        
        // 获取附件和字符数组，计算附件在文本容器中的位置
        let runs = CTLineGetGlyphRuns(cTLine)
        let runCount = CFArrayGetCount(runs)
        if runCount == 0 {
            return
        }
        
        var attachments: [WLTextAttachment] = []
        var attachmentRanges: [NSRange] = []
        var attachmentRects: [CGRect] = []
        var glyphsArray: [WLTextGlyph] = []
        
        for i in 0..<runCount {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, i), to: CTRun.self)
            let glyphCount = CTRunGetGlyphCount(run)
            let attributes = CTRunGetAttributes(run) as NSDictionary
            
            let runRange = CTRunGetStringRange(run)
            let range = NSRange(location: runRange.location, length: runRange.length)
            
            guard glyphCount > 0 else { continue }
            
            // 字符数组
            let glyphs = UnsafeMutablePointer<CGGlyph>.allocate(capacity: glyphCount)
            CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs)
            
            // 字符原点
            let glyphPositions = UnsafeMutablePointer<CGPoint>.allocate(capacity: glyphCount)
            CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions)
            
            // 字符大小
            let glyphAdvances = UnsafeMutablePointer<CGSize>.allocate(capacity: glyphCount)
            CTRunGetAdvances(run, CFRangeMake(0, glyphCount), glyphAdvances)
            
            for i in 0..<glyphCount {
                let glyph = WLTextGlyph.init(glyph: glyphs[i])
                glyph.position = glyphPositions[i]
                glyph.leading = leading;
                glyph.ascent = ascent;
                glyph.descent = descent;
                glyph.width = glyphAdvances[i].width
                glyph.height = glyphAdvances[i].height
                glyphsArray.append(glyph)
            }
            
            guard let attachment = attributes.value(forKey: WLAttributedStringKey.attachment.rawValue) as? WLTextAttachment else {
                continue
            }
            
            var runPosition: CGPoint = .zero
            CTRunGetPositions(run, CFRange(location: 0, length: 1), &runPosition)
            
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            let runWidth = CGFloat(CTRunGetTypographicBounds(run, CFRange(location: 0, length: 0), &ascent, &descent, &leading))
            runPosition.x += self.lineOrigin.x
            runPosition.y = self.lineOrigin.y - runPosition.y
            let runTypoBounds = CGRect(x: runPosition.x,
                                       y: runPosition.y - ascent,
                                       width: runWidth,
                                       height: ascent + descent)
            
            
            
            attachments.append(attachment)
            attachmentRanges.append(range)
            attachmentRects.append(runTypoBounds)
        }
        
        self.attachments = attachments
        self.attachmentRanges = attachmentRanges
        self.attachmentRects = attachmentRects
        self.glyphs = glyphsArray
    }
    
}

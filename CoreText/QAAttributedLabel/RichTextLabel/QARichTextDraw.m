//
//  QARichTextDraw.m
//  CoreText
//
//  Created by Avery An on 2020/2/27.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QARichTextDraw.h"
#import "QAAttributedLabelConfig.h"
#import "QATextRunDelegate.h"

@implementation NSMutableAttributedString (QARichTextDraw)

- (int)drawAttributedTextWithContext:(CGContextRef)context
                         contentSize:(CGSize)contentSize
                           wordSpace:(CGFloat)wordSpace
                    maxNumberOfLines:(NSInteger)maxNumberOfLines
                       textAlignment:(NSTextAlignment)textAlignment
                   saveHighlightText:(BOOL)saveHighlightText
                           justified:(BOOL)justified {
    if (context == NULL || CGSizeEqualToSize(contentSize, CGSizeZero)) {
        return -10;
    }
    
    NSMutableAttributedString *attributedString = self;
    if (attributedString.highlightFrameDic &&
        attributedString.highlightFrameDic.count > 0) {   // 无需再次获取highlightFrameDic的值
        saveHighlightText = NO;
    }
    
    @autoreleasepool {
        if (saveHighlightText) { // 保存TextInfo的情况
            [self getSortedHighlightRanges:attributedString];
        }
        
        CGFloat contentHeight = contentSize.height;
        CGFloat contentWidth = contentSize.width;
        
        // 翻转坐标系:
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, contentHeight);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // 基于attributedString创建CTFramesetter:
        CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
        
        // 创建绘制路径path:
        CGRect drawRect = (CGRect) {0, 0, contentSize};
        CGMutablePathRef drawPath = CGPathCreateMutable();
        CGPathAddRect(drawPath, NULL, drawRect);
        
        // 创建CTFrame:
        CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, 0), drawPath, NULL);
        /*
         CTFrameDraw(ctFrame, context);
         */
        
        // 从CTFrame中获取所有的CTLine:
        CFArrayRef lines = CTFrameGetLines(ctFrame);
        NSInteger numberOfLines = CFArrayGetCount(lines);  // 展示文案所需要的总行数
        CGPoint lineOrigins[numberOfLines];
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, numberOfLines), lineOrigins);
        
        // 遍历CTFrame中的每一行CTLine:
        for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
            CGPoint lineOrigin = lineOrigins[lineIndex];
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
            
            CGFloat lineDescent = 0.0f, lineAscent = 0.0f, lineLeading = 0.0f;
            double lineWidth = CTLineGetTypographicBounds((CTLineRef)line, &lineAscent, &lineDescent, &lineLeading);
            CGFloat lineHeight = lineAscent + lineDescent;
            CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, QAFlushFactorForTextAlignment(textAlignment), drawRect.size.width); // 获取绘制文本时光笔所需的偏移量
            CGContextSetTextPosition(context, penOffset, lineOrigin.y); // 设置每一行位置
            if (justified && lineIndex == numberOfLines - 1 && lineWidth / contentWidth > 0.80) { // 处理最后一行
                line = CTLineCreateJustifiedLine(line, 1, contentWidth);  // 设置最后一行的两端对齐(当添加了"...全文"之后的情况)
                CTLineDraw(line, context); // 绘制每一行的内容
            }
            else {
                CTLineDraw(line, context); // 绘制每一行的内容
            }
            
            
            [self drawAttachment:line
               saveHighlightText:saveHighlightText
                         context:context
                         ctFrame:ctFrame
                   ctFramesetter:ctFramesetter
                        drawPath:drawPath
                      lineOrigin:lineOrigin
                       wordSpace:wordSpace
                       lineIndex:lineIndex
                      lineHeight:lineHeight
                   contentHeight:contentHeight];
        }
        
        CFRelease(drawPath);
        CFRelease(ctFrame);
        CFRelease(ctFramesetter);
    }
    
    return 0;
}

@end

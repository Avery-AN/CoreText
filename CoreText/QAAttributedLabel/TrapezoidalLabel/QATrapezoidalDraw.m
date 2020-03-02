//
//  QATrapezoidalDraw.m
//  CoreText
//
//  Created by Avery An on 2020/2/27.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QATrapezoidalDraw.h"
#import "QAAttributedLabelConfig.h"

@implementation NSMutableAttributedString (QATrapezoidalDraw)

- (int)drawWithTrapezoidalLineHeight:(NSInteger)trapezoidalLineHeight
                    contentSize:(CGSize)contentSize
                      wordSpace:(CGFloat)wordSpace
        textAlignment:(NSTextAlignment)textAlignment
          leftGap:(CGFloat)leftGap
         rightGap:(CGFloat)rightGap
          context:(CGContextRef)context
            lines:(NSArray *)lines
              saveHighlightText:(BOOL)saveHighlightText {
    if (context == NULL || CGSizeEqualToSize(contentSize, CGSizeZero)) {
        return -10;
    }
    
        @autoreleasepool {
            // 翻转坐标系:
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextTranslateCTM(context, 0, contentSize.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            // 绘制line:
            NSInteger numberOfLines = lines.count;
            for (int lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
                id obj = [lines objectAtIndex:lineIndex];
                CTLineRef line = (__bridge CTLineRef)obj;
                
                CGFloat descent = 0.0f, ascent = 0.0f, leading = 0.0f;
                CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
                CGFloat lineHeight = ascent + fabs(descent) + leading;  // ascent & descent & leading的值由字体来确定、无法修改。
                CGFloat textHeight = ascent + fabs(descent);
                
                CGRect rect_line = CTLineGetImageBounds(line, context);
                NSInteger lineWidth = ceil(rect_line.size.width);   // 文字的最左端与文字的最右端之间的距离
                NSLog(@"lineWidth(绘制): %ld",lineWidth);
                
                CGFloat penOffset = 0;
                if (textAlignment == NSTextAlignmentLeft) {
                    penOffset = leftGap;  // 左对齐
                }
                else if (textAlignment == NSTextAlignmentRight) {
                    penOffset = contentSize.width - rightGap - lineWidth;  // 右对齐
                }
                else {
                    penOffset = (contentSize.width - lineWidth) / 2.;   // 居中对齐
                }
                
                
                /**
                 CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, .5, contentSize.width);  // 居中对齐
                 CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, 0, contentSize.width) + DrawBackground_LeftGap;  // 左对齐
                 CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, 1, contentSize.width) - DrawBackground_RightGap; // 右对齐
                 */
                
                
                CGFloat offsetY = ((lines.count-1)-lineIndex)*trapezoidalLineHeight + (trapezoidalLineHeight - textHeight)/2 + fabs(descent);
                offsetY = offsetY + contentSize.height-(lines.count * trapezoidalLineHeight);
                CGContextSetTextPosition(context, penOffset, offsetY);
                CTLineDraw(line, context);
                
            }
        }
    
    return 0;
}


//- (int)drawWithTrapezoidalLineHeight:(NSInteger)trapezoidalLineHeight
//                    contentSize:(CGSize)contentSize
//                      wordSpace:(CGFloat)wordSpace
//                  textAlignment:(NSTextAlignment)textAlignment
//                   leftGap:(CGFloat)leftGap
//                  rightGap:(CGFloat)rightGap
//                        context:(CGContextRef)context
//                          lines:(NSArray *)lines
//              saveHighlightText:(BOOL)saveHighlightText {
//    if (context == NULL || CGSizeEqualToSize(contentSize, CGSizeZero)) {
//        return -10;
//    }
//
//    NSMutableAttributedString *attributedString = self;
//    if (attributedString.highlightFrameDic &&
//        attributedString.highlightFrameDic.count > 0) {   // 无需再次获取highlightFrameDic的值
//        saveHighlightText = NO;
//    }
//
//    @autoreleasepool {
//        if (saveHighlightText) { // 保存TextInfo的情况
//            [self getSortedHighlightRanges:attributedString];
//        }
//
//        // 翻转坐标系:
//        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//        CGContextTranslateCTM(context, 0, contentSize.height);
//        CGContextScaleCTM(context, 1.0, -1.0);
//
//
//        NSInteger numberOfLines = lines.count;
////        CGPoint lineOrigins[numberOfLines];
////        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, numberOfLines), lineOrigins);
//
//
//        // 绘制line:
//        for (int lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
//            id obj = [lines objectAtIndex:lineIndex];
//            CTLineRef line = (__bridge CTLineRef)obj;
//
//
//
//
//            CGFloat descent = 0.0f, ascent = 0.0f, leading = 0.0f;
//            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
//            CGFloat lineHeight = ascent + fabs(descent) + leading;  // ascent & descent & leading的值由字体来确定、无法修改。
//            CGFloat textHeight = ascent + fabs(descent);
//
//
//            CGRect rect_line = CTLineGetImageBounds(line, context);
//            NSInteger lineWidth = ceil(rect_line.size.width);   // 文字的最左端与文字的最右端之间的距离
//            NSLog(@"lineWidth(绘制): %ld",lineWidth);
//
//            CGFloat penOffset = 0;
//            if (textAlignment == NSTextAlignmentLeft) {
//                penOffset = leftGap;  // 左对齐
//            }
//            else if (textAlignment == NSTextAlignmentRight) {
//                penOffset = contentSize.width - rightGap - lineWidth;  // 右对齐
//            }
//            else {
//                penOffset = (contentSize.width - lineWidth) / 2.;   // 居中对齐
//            }
//
//    //        CGFloat penOffset = (contentSize.width - lineWidth) / 2.;   // 居中对齐
//    //        CGFloat penOffset = DrawBackground_LeftGap;  // 左对齐
//    //        CGFloat penOffset = contentSize.width - DrawBackground_RightGap - lineWidth;  // 右对齐
//
//
//
//            /**
//             CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, .5, contentSize.width);  // 居中对齐
//             CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, 0, contentSize.width) + DrawBackground_LeftGap;  // 左对齐
//             CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, 1, contentSize.width) - DrawBackground_RightGap; // 右对齐
//             */
//
//
////            CGFloat offsetY = ((lines.count-1)-lineIndex)*trapezoidalLineHeight + (trapezoidalLineHeight - textHeight)/2 + descent;
////            CGFloat offsetY = lineIndex*trapezoidalLineHeight + (trapezoidalLineHeight - textHeight)/2 + descent;
//
//            CGFloat offsetY = ((lines.count-1)-lineIndex)*trapezoidalLineHeight + (trapezoidalLineHeight - textHeight)/2 + fabs(descent);
//            CGContextSetTextPosition(context, penOffset, offsetY);
//            CTLineDraw(line, context);
//
////            [self drawAttachment:line
////               saveHighlightText:saveHighlightText
////                         context:context
////                         ctFrame:NULL
////                   ctFramesetter:NULL
////                        drawPath:NULL
////                      lineOrigin:lineOrigin
////                       wordSpace:wordSpace
////                       lineIndex:lineIndex
////                      lineHeight:lineHeight
////                   contentHeight:contentHeight];
//        }
//    }
//    return 0;
//}

@end

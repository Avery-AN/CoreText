//
//  QATrapezoidalLayer.m
//  CoreText
//
//  Created by Avery An on 2020/2/27.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QATrapezoidalLayer.h"
#import "QATrapezoidalDraw.h"
#import "QATrapezoidalLabel.h"
#import "QABackgroundDraw.h"

@implementation QATrapezoidalLayer

#pragma mark - Override Methods -
- (void)display {
    QATrapezoidalLabel *attributedLabel = (QATrapezoidalLabel *)self.delegate;
    [self performSelector:@selector(fillContents_async:) withObject:attributedLabel];
}


#pragma mark - Private Methods -
/**
 获取AttributedString
 */
- (void)getDrawAttributedTextWithLabel:(QAAttributedLabel *)attributedLabel
                            selfBounds:(CGRect)bounds
                   checkAttributedText:(BOOL(^)(NSString *content))checkBlock
                            completion:(void(^)(id attributedTextObj))completion {
    CGFloat boundsWidth = bounds.size.width;
    QATrapezoidalLabel *label = (QATrapezoidalLabel *)attributedLabel;
    NSArray *trapezoidalTexts = label.trapezoidalTexts;
    if (!trapezoidalTexts || trapezoidalTexts.count == 0) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    @autoreleasepool {
        NSMutableArray *trapezoidalAttributedTexts = [NSMutableArray array];
        for (NSString *content in trapezoidalTexts) {
            NSMutableAttributedString *attributedText = [self getAttributedStringWithString:content
                                                                                   maxWidth:boundsWidth];
            [trapezoidalAttributedTexts addObject:attributedText];
        }
        if (completion) {
            completion(trapezoidalAttributedTexts);
        }
    }
}

/**
 获取文案所对应的AttributedString并保存相关的属性
 */
- (NSMutableAttributedString * _Nullable)getAttributedStringWithString:(NSString * _Nonnull)content
                                                              maxWidth:(CGFloat)maxWidth {
    NSString *showContent = [content copy];
    QAAttributedLabel *attributedLabel = (QAAttributedLabel *)self.delegate;
    
    NSMutableAttributedString *attributedString = nil;
    NSMutableDictionary *highlightContents = nil;
    NSMutableDictionary *highlightRanges = nil;
    
    [self getAttributedString:&attributedString
            highlightContents:&highlightContents
              highlightRanges:&highlightRanges
                  withContent:showContent];
    
    [self processDiyEmojiText:attributedString
                        label:attributedLabel
            highlightContents:highlightContents
              highlightRanges:highlightRanges];
    
    [self setSetedHighlightTexts:attributedString label:attributedLabel];
    
    [self setHighlightTexts:attributedString highlightRanges:highlightRanges];

    [self saveAttributedTextInfo:attributedString
               highlightContents:highlightContents
                 highlightRanges:highlightRanges
                           label:attributedLabel];
    
    return attributedString;
}

/**
 开始绘制AttributedText
 */
- (int)beginDrawAttributedText:(id)attributedTextObj
                         label:(QAAttributedLabel *)attributedLabel
                    selfBounds:(CGRect)bounds
                       context:(CGContextRef)context
           checkAttributedText:(BOOL(^)(NSString *content))checkBlock {
    
    NSMutableArray *attributedTexts = attributedTextObj;
    CGFloat boundsWidth = bounds.size.width;
    CGFloat boundsHeight = bounds.size.height;
    CGSize contentSize = CGSizeMake(ceil(boundsWidth), ceil(boundsHeight));
    [self drawAttributedString:attributedTexts
                       context:context
                   contentSize:contentSize
                     wordSpace:attributedLabel.wordSpace
                 numberOfLines:0   // 统一设为0 (展示全部文案)
                 textAlignment:attributedLabel.textAlignment
             saveHighlightText:YES];
    
    
//    // 处理搜索结果:
//    if (attributedText.searchRanges && attributedText.searchRanges.count > 0) {
//        UIColor *textColor = [attributedText.searchAttributeInfo valueForKey:@"textColor"];
//        UIColor *textBackgroundColor = [attributedText.searchAttributeInfo valueForKey:@"textBackgroundColor"];
//        for (NSString *rangeString in attributedText.searchRanges) {
//            NSRange range = NSRangeFromString(rangeString);
//            int result = [self updateAttributeText:attributedText
//                                           withTextColor:textColor
//                                     textBackgroundColor:textBackgroundColor
//                                                   range:range];
//            if (result < 0) {
//                if (cancel) {
//                    cancel();
//                }
//                return -1;
//            }
//        }
//    }
//
//    // 保存高亮相关信息(link & at & Topic & Seemore)到attributedText对应的属性中:
//    int saveResult = [self saveHighlightRanges:attributedText.highlightRanges
//                                   highlightContents:attributedText.highlightContents
//                                      truncationInfo:attributedText.truncationInfo
//                                     attributedLabel:attributedLabel
//                                    attributedString:attributedText];
//    if (saveResult < 0) {
//        if (cancel) {
//            cancel();
//        }
//        return -1;
//    }
//
//    // 文案的绘制:
//    CGFloat boundsWidth = bounds.size.width;
//    CGFloat boundsHeight = bounds.size.height;
//    CGSize contentSize = CGSizeMake(ceil(boundsWidth), ceil(boundsHeight));
//    NSInteger numberOfLines = attributedLabel.numberOfLines;
//    BOOL justified = NO;
//    if (attributedText.showMoreTextEffected && attributedLabel.textAlignment == NSTextAlignmentJustified) {
//        justified = YES;
//    }
//    int drawResult = [self drawAttributedString:attributedText
//                                        context:context
//                                    contentSize:contentSize
//                                      wordSpace:attributedLabel.wordSpace
//                                  numberOfLines:numberOfLines
//                                  textAlignment:attributedLabel.textAlignment
//                              saveHighlightText:YES];
//    if (drawResult < 0) {
//        if (cancel) {
//            cancel();
//        }
//        return -1;
//    }
//
//    // 更新搜索数据到数据源中:
//    SEL appendDrawResultSelector = NSSelectorFromString(@"appendDrawResult:");
//    IMP appendDrawResultImp = [attributedLabel methodForSelector:appendDrawResultSelector];
//    void (*appendDrawResult)(id, SEL, NSMutableAttributedString *) = (void *)appendDrawResultImp;
//    appendDrawResult(attributedLabel, appendDrawResultSelector, attributedText);
    
    return 0;
}

/**
 文案的绘制
 */
- (int)drawAttributedString:(NSMutableArray *)trapezoidalTexts
                    context:(CGContextRef)context
                contentSize:(CGSize)contentSize
                  wordSpace:(NSInteger)wordSpace
              numberOfLines:(NSInteger)numberOfLines
              textAlignment:(NSTextAlignment)textAlignment
          saveHighlightText:(BOOL)saveHighlightText {
    
    QATrapezoidalLabel *attributedLabel = (QATrapezoidalLabel *)self.delegate;
    NSInteger trapezoidalLineHeight = attributedLabel.trapezoidalLineHeight;
    if (trapezoidalLineHeight - attributedLabel.font.pointSize <= 3) {  // 异常处理
        trapezoidalLineHeight = attributedLabel.font.pointSize + 6;
    }
    
    // 设置左右间距(背景色和文字之间的间隔):
    CGFloat leftGap = 10;
    CGFloat rightGap = leftGap;
    
    // 创建CTLineRef & 更新trapezoidalTexts:
    NSMutableArray *trapezoidalTexts_new = [NSMutableArray array];
    NSMutableArray *lineWidths = [NSMutableArray array];
    NSMutableArray *lines = [NSMutableArray array];
    for (NSAttributedString *attributedString in trapezoidalTexts) {
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
         
         [self updateLine:line
                  context:context
         attributedString:attributedString
             maxLineWidth:contentSize.width
                  leftGap:leftGap
                 rightGap:rightGap
                    lines:lines
               lineWidths:lineWidths
        trapezoidalTexts:trapezoidalTexts_new];
    }
    
    /**
     if (trapezoidalTexts_new.count != trapezoidalTexts.count) {
         UIGraphicsEndImageContext();

         // 给上下文填充背景色:
         CGContextSetFillColorWithColor(context, attributedLabel.backgroundColor.CGColor);
         CGContextFillRect(context, attributedLabel.bounds);

         UIGraphicsBeginImageContextWithOptions(contentSize, YES, 0);
         context = UIGraphicsGetCurrentContext();
     }
     */
    
    // 设置绘制背景:
    if (textAlignment == NSTextAlignmentCenter) {
        [QABackgroundDraw drawBackgroundWithMaxWidth:contentSize.width
                                       lineWidths:lineWidths
                                       lineHeight:trapezoidalLineHeight
                                           radius:6
                                    textAlignment:Background_TextAlignment_Center
                                  backgroundColor:attributedLabel.highlightTextBackgroundColor];
    }
    else if (textAlignment == NSTextAlignmentLeft) {
        [QABackgroundDraw drawBackgroundWithMaxWidth:contentSize.width
                                       lineWidths:lineWidths
                                       lineHeight:trapezoidalLineHeight
                                           radius:6
                                    textAlignment:Background_TextAlignment_Left
                                    backgroundColor:attributedLabel.highlightTextBackgroundColor];
    }
    else if (textAlignment == NSTextAlignmentRight) {
        [QABackgroundDraw drawBackgroundWithMaxWidth:contentSize.width
                                       lineWidths:lineWidths
                                       lineHeight:trapezoidalLineHeight
                                           radius:6
                                    textAlignment:Background_TextAlignment_Right
                                    backgroundColor:attributedLabel.highlightTextBackgroundColor];
    }
    
    
    
//    for (NSMutableAttributedString *attributedText in trapezoidalTexts) {
//        int result = [attributedText drawWithTrapezoidalLineHeight:trapezoidalLineHeight
//                                                       contentSize:contentSize
//                                                         wordSpace:wordSpace
//                                                     textAlignment:attributedLabel.textAlignment
//                                                           leftGap:leftGap
//                                                          rightGap:rightGap
//                                                           context:context
//                                                             lines:lines
//                                                 saveHighlightText:saveHighlightText];
//        return result;
//    }
    
    NSMutableAttributedString *_attributedText_ = [[NSMutableAttributedString alloc] initWithString:@""];
    int result = [_attributedText_ drawWithTrapezoidalLineHeight:trapezoidalLineHeight
                                                   contentSize:contentSize
                                                     wordSpace:wordSpace
                                                 textAlignment:attributedLabel.textAlignment
                                                       leftGap:leftGap
                                                      rightGap:rightGap
                                                       context:context
                                                         lines:lines
                                             saveHighlightText:saveHighlightText];
    return result;
    
    return 0;
}

- (void)updateLine:(CTLineRef)line
           context:(CGContextRef)context
  attributedString:(NSAttributedString *)attributedString
      maxLineWidth:(NSInteger)maxLineWidth
           leftGap:(CGFloat)leftGap
          rightGap:(CGFloat)rightGap
             lines:(NSMutableArray *)lines
        lineWidths:(NSMutableArray *)lineWidths
  trapezoidalTexts:(NSMutableArray *)trapezoidalTexts {
    CGRect rect_line = CTLineGetImageBounds(line, context);
    NSInteger lineWidth = ceil(rect_line.size.width);
    if (lineWidth - maxLineWidth > 0) {   // 特殊情况
        [self updateLinesWithAttributedString:attributedString
                                 maxLineWidth:maxLineWidth
                                      leftGap:leftGap
                                     rightGap:rightGap
                                      context:context
                                        lines:lines
                                   lineWidths:lineWidths
                            trapezoidalTexts:trapezoidalTexts];
    }
    else {
        [lines addObject:(__bridge id)line];
        lineWidth = lineWidth + leftGap + rightGap;
        NSLog(@"lineWidth(背景): %ld",lineWidth);
        [lineWidths addObject:[NSString stringWithFormat:@"%ld",lineWidth]];
        [trapezoidalTexts addObject:attributedString];
    }
}

- (void)updateLinesWithAttributedString:(NSAttributedString *)attributedString
                           maxLineWidth:(CGFloat)maxLineWidth
                                leftGap:(CGFloat)leftGap
                               rightGap:(CGFloat)rightGap
                                context:(CGContextRef)context
                                  lines:(NSMutableArray *)lines
                             lineWidths:(NSMutableArray *)lineWidths
                      trapezoidalTexts:(NSMutableArray *)trapezoidalTexts {
    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    
    // 创建CTFrame:
    CGSize contentSize = CGSizeMake(maxLineWidth, CGFLOAT_MAX);
    CGRect rect = (CGRect){0, 0, contentSize};
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, attributedString.length), path, NULL);
    
    // 从CTFrame中获取所有的CTLine:
    CFArrayRef allLines = CTFrameGetLines(ctFrame);
    NSInteger numberOfAllLines = CFArrayGetCount(allLines);
    
    for (int lineIndex = 0; lineIndex < numberOfAllLines; lineIndex++) {
        CTLineRef lineRef = CFArrayGetValueAtIndex(allLines, lineIndex);
        CFRange cfrange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(cfrange.location, cfrange.length);
        NSAttributedString *subAttributedString = [attributedString attributedSubstringFromRange:range];
        
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)subAttributedString);
        CGRect rect_line = CTLineGetImageBounds(line, context);
        NSInteger lineWidth = ceil(rect_line.size.width);
        
        [lines addObject:(__bridge id)line];
        lineWidth = lineWidth + leftGap + rightGap;
        [lineWidths addObject:[NSString stringWithFormat:@"%ld",lineWidth]];
        [trapezoidalTexts addObject:attributedString];
    }
}

@end

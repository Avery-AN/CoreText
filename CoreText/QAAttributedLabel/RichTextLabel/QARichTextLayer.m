//
//  QARichTextLayer.m
//  CoreText
//
//  Created by Avery An on 2020/2/27.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QARichTextLayer.h"
#import "QARichTextDraw.h"
#import "QAAttributedLabel.h"

@implementation QARichTextLayer

- (void)getDrawAttributedTextWithLabel:(QAAttributedLabel *)attributedLabel
                            selfBounds:(CGRect)bounds
                   checkAttributedText:(BOOL(^)(NSString *content))checkBlock
                            completion:(void(^)(id attributedTextObj))completion {
    NSString *content = attributedLabel.text;
    CGFloat boundsWidth = bounds.size.width;
    
    NSMutableAttributedString *attributedText = nil;
    if (attributedLabel.srcAttributedString && attributedLabel.attributedString && attributedLabel.attributedString.string.length > 0) {
        attributedText = attributedLabel.attributedString;
        if (self.renderText == nil) {
            self.renderText = attributedLabel.attributedString;
        }
        
        if (completion) {
            completion(attributedText);
        }
        
        
        /**
         // 获取缓存 (mmap 会造成内存瞬间暴涨):
         __weak typeof(self) weakSelf = self;
         [self getCacheWithIdentifier:attributedText
                             finished:^(NSMutableAttributedString * _Nonnull identifier, UIImage * _Nullable image) {
             __strong typeof(weakSelf) strongSelf = weakSelf;

             if (image) {   // Hit Cache
                 NSLog(@"    Hit Cache ~~~");

                 UIGraphicsEndImageContext();
                 strongSelf.currentCGImage = (__bridge id _Nullable)(image.CGImage);
                 strongSelf.contents = nil;
                 strongSelf.contents = strongSelf.currentCGImage;
                 strongSelf->_drawState = QAAttributedLayer_State_Finished;
                 CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
                 CFAbsoluteTime loadTime = endTime - strongSelf->startTime_beginDraw;
                 NSLog(@"loadTime(Mmap-Cache): %f",loadTime);
                 NSLog(@" ");
                 return;
             }
             else {   // Not Hit Cache
                 NSLog(@"   Not Hit Cache ~~~");

                 if (completion) {
                     completion(attributedText, YES);
                 }
             }
         }];
         */
        
        
        /*
         if (attributedLabel.attributedString) {
             attributedText = [self getAttributedStringWithAttributedString:attributedLabel.attributedString
                                                                   maxWidth:boundsWidth];
             
             if (self.attributedText_backup) {
                 self->_attributedText_backup = attributedText;
                 self->_text_backup = nil;
             }
         }
         */
    }
    else {
        NSLog(@"生成attributedText");
        attributedText = [self getAttributedStringWithString:content
                                                    maxWidth:boundsWidth];
        
        [self backUpAttributedString:attributedText];
        if (!attributedText) {
            if (completion) {
                completion(nil);
            }
            return;
        }
        
        if (completion) {
            completion(attributedText);
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
    NSMutableDictionary *highlightContents = [NSMutableDictionary dictionary];
    NSMutableDictionary *highlightRanges = [NSMutableDictionary dictionary];
    
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
    
    [self processSeeMoreText:&attributedString
                       label:attributedLabel
                    maxWidth:maxWidth
           highlightContents:highlightContents
             highlightRanges:highlightRanges];
    
    [self saveAttributedTextInfo:attributedString
               highlightContents:highlightContents
                 highlightRanges:highlightRanges
                           label:attributedLabel];
    
    return attributedString;
}
- (int)beginDrawAttributedText:(id)attributedTextObj
                         label:(QAAttributedLabel *)attributedLabel
                    selfBounds:(CGRect)bounds
                       context:(CGContextRef)context
           checkAttributedText:(BOOL(^)(NSString *content))checkBlock {
    NSMutableAttributedString *attributedText = attributedTextObj;  //此处为NSMutableAttributedString类型的数据
    if (![attributedText isKindOfClass:[NSMutableAttributedString class]]) {
        return -1;
    }
    
    // 处理搜索结果:
    if (attributedText.searchRanges && attributedText.searchRanges.count > 0) {
        UIColor *textColor = [attributedText.searchAttributeInfo valueForKey:@"textColor"];
        UIColor *textBackgroundColor = [attributedText.searchAttributeInfo valueForKey:@"textBackgroundColor"];
        for (NSString *rangeString in attributedText.searchRanges) {
            NSRange range = NSRangeFromString(rangeString);
            int result = [self updateAttributeText:attributedText
                                           withTextColor:textColor
                                     textBackgroundColor:textBackgroundColor
                                                   range:range];
            if (result < 0) {
                return -1;
            }
        }
    }
    
    // 保存高亮相关信息(link & at & Topic & Seemore)到attributedText对应的属性中:
    int saveResult = [self saveHighlightRanges:attributedText.highlightRanges
                                   highlightContents:attributedText.highlightContents
                                      truncationInfo:attributedText.truncationInfo
                                     attributedLabel:attributedLabel
                                    attributedString:attributedText];
    if (saveResult < 0) {
        return -1;
    }
    
    // 文案的绘制:
    CGFloat boundsWidth = bounds.size.width;
    CGFloat boundsHeight = bounds.size.height;
    CGSize contentSize = CGSizeMake(ceil(boundsWidth), ceil(boundsHeight));
    NSInteger numberOfLines = attributedLabel.numberOfLines;
    BOOL justified = NO;
    if (attributedText.showMoreTextEffected && attributedLabel.textAlignment == NSTextAlignmentJustified) {
        justified = YES;
    }
    int drawResult = [self drawAttributedString:attributedText
                                        context:context
                                    contentSize:contentSize
                                      wordSpace:attributedLabel.wordSpace
                                  numberOfLines:numberOfLines
                                  textAlignment:attributedLabel.textAlignment
                              saveHighlightText:YES
                                      justified:justified];
    if (drawResult < 0) {
        return -1;
    }

    // 更新搜索数据到数据源中:
    SEL appendDrawResultSelector = NSSelectorFromString(@"appendDrawResult:");
    IMP appendDrawResultImp = [attributedLabel methodForSelector:appendDrawResultSelector];
    void (*appendDrawResult)(id, SEL, NSMutableAttributedString *) = (void *)appendDrawResultImp;
    appendDrawResult(attributedLabel, appendDrawResultSelector, attributedText);
    
    return 0;
}

/**
 文案的绘制
 */
- (int)drawAttributedString:(NSMutableAttributedString *)attributedText
                    context:(CGContextRef)context
                contentSize:(CGSize)contentSize
                  wordSpace:(NSInteger)wordSpace
              numberOfLines:(NSInteger)numberOfLines
              textAlignment:(NSTextAlignment)textAlignment
          saveHighlightText:(BOOL)saveHighlightText
                  justified:(BOOL)justified {
    int result = [attributedText drawAttributedTextWithContext:context
                                                   contentSize:contentSize
                                                     wordSpace:wordSpace
                                              maxNumberOfLines:numberOfLines
                                                 textAlignment:textAlignment
                                             saveHighlightText:saveHighlightText
                                                     justified:justified];
    return result;
}


@end

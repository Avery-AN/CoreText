//
//  QATextDrawer.m
//  CoreText
//
//  Created by Avery on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import "QATextDrawer.h"
#import "QAAttributedLabelConfig.h"

typedef NS_ENUM(NSUInteger, HighlightContentPosition) {
    HighlightContentPosition_Null = 0,
    HighlightContentPosition_Header,
    HighlightContentPosition_Middle,
    HighlightContentPosition_Taile
};

static inline CGFloat QAFlushFactorForTextAlignment(NSTextAlignment textAlignment) {
    switch (textAlignment) {
        case NSTextAlignmentCenter:
            return .5;
        case NSTextAlignmentRight:
            return 1.;
        case NSTextAlignmentLeft:
            return 0.;
        default:
            return 0.;
    }
}


@interface QATextDrawer () {
    NSString *_previousHighlightKey;
    NSRange _previousHighlightRange;
    NSInteger _previousHighlightRangeTotalLength;
    NSMutableDictionary *_saveDoneDic;
}
@property (nonatomic, assign) HighlightContentPosition highlightContentPosition;

/**
 保存需要设为高亮的文案所处的位置
 */
@property (nonatomic, strong) NSMutableArray *highlightRanges;

/**
 保存需要设为高亮的文案的字体
 */
@property (nonatomic, strong) NSMutableArray *highlightFonts;
@end


@implementation QATextDrawer

#pragma mark - Life Cycle -
- (void)dealloc {
//    NSLog(@"%s",__func__);
    
//    if (_ctFrame) {
//        CFRelease(_ctFrame);
//        _ctFrame = nil;
//    }
}
- (instancetype)init {
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}
- (void)setUp {
    self.highlightFonts = [NSMutableArray array];
    self.highlightRanges = [NSMutableArray array];
    self.highlightFrameDic = [NSMutableDictionary dictionary];
    
    self.textTypeDic = [NSMutableDictionary dictionary];
    self.textDic = [NSMutableDictionary dictionary];
    self.textNewlineDic = [NSMutableDictionary dictionary];
    self.textFontDic = [NSMutableDictionary dictionary];
    self.textForwardColorDic = [NSMutableDictionary dictionary];
    self.textBackgroundColorDic = [NSMutableDictionary dictionary];
}


#pragma mark - Public Apis -
/**
 根据size的大小在context里绘制文本attributedString
 */
- (void)drawText:(NSMutableAttributedString *)attributedString
         context:(CGContextRef)context
     contentSize:(CGSize)size {
    if (context == NULL) {
        return;
    }
    else if (!attributedString) {
        return;
    }
    
    @autoreleasepool {
        // 翻转坐标系:
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // 创建ctFramesetter:
        CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
        
        // 创建绘制路径path:
        CGRect drawRect = (CGRect){0, 0, size};
        CGMutablePathRef drawPath = CGPathCreateMutable();
        CGPathAddRect(drawPath, NULL, drawRect);
        
        // 创建ctFrame:
        CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, 0), drawPath, NULL);
        
        // 绘制:
        CTFrameDraw(ctFrame, context);
        
        // 释放:
        CFRelease(drawPath);
        CFRelease(ctFrame);
        CFRelease(ctFramesetter);
    }
}

- (int)drawText:(NSMutableAttributedString *)attributedString
        context:(CGContextRef)context
    contentSize:(CGSize)size
      wordSpace:(CGFloat)wordSpace
maxNumberOfLines:(NSInteger)maxNumberOfLines
  textAlignment:(NSTextAlignment)textAlignment
 truncationText:(NSDictionary *)truncationTextInfo
 isSaveTextInfo:(BOOL)isSave
          check:(BOOL(^)(NSString *content))check
         cancel:(void(^)(void))cancel {
    if (context == NULL || !attributedString || CGSizeEqualToSize(size, CGSizeZero)) {
        return -1;
    }
    
    // 异常处理:
    if (check && check(attributedString.string)) {
        if (cancel) {
            cancel();
        }
        return -1;
    }
    
    @autoreleasepool {
        // 先清空数据
        [self.highlightFrameDic removeAllObjects];
        [self.highlightFonts removeAllObjects];
        [self.highlightRanges removeAllObjects];
        [self.textNewlineDic removeAllObjects];
        
        // 保存TextInfo的情况
        if (isSave) {
            // 保存高亮文案的highlightRange & highlightFont:
            if (self.textFontDic && self.textFontDic.count > 0) {
                NSArray *allkeys = [self.textFontDic allKeys];
                for (NSString *rangeKey in allkeys) { // highlightRanges & highlightFonts数组中的元素表示某一个高亮字符串的range与font (需要注意:数组中元素的index不能乱)
                    if (self.highlightRanges.count == 0) {
                        [self.highlightRanges addObject:rangeKey];
                        
                        UIFont *font = (UIFont *)[self.textFontDic valueForKey:rangeKey];
                        [self.highlightFonts addObject:font];
                    }
                    else {
                        NSRange range_current = NSRangeFromString(rangeKey);
                        int position = 0;
                        for (int k = 0; k < self.highlightRanges.count; k++) {
                            NSRange range_previous = NSRangeFromString([self.highlightRanges objectAtIndex:k]);
                            if (range_current.location > range_previous.location) {
                                position++;
                            }
                        }
                        
                        if (self.highlightRanges.count > position) {
                            [self.highlightRanges insertObject:rangeKey atIndex:position];
                            UIFont *font = (UIFont *)[self.textFontDic valueForKey:rangeKey];
                            [self.highlightFonts insertObject:font atIndex:position];
                        }
                        else {
                            [self.highlightRanges addObject:rangeKey];
                            
                            UIFont *font = (UIFont *)[self.textFontDic valueForKey:rangeKey];
                            [self.highlightFonts addObject:font];
                        }
                    }
                    
                }
            }
        }
        
        // 翻转坐标系:
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // 基于attributedString创建CTFramesetter:
        CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
        
        // 创建绘制路径path:
        CGRect drawRect = (CGRect) {0, 0, size};
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
            CTLineGetTypographicBounds((CTLineRef)line, &lineAscent, &lineDescent, &lineLeading);
            CGFloat lineHeight = lineAscent + lineDescent;
            CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, QAFlushFactorForTextAlignment(textAlignment), drawRect.size.width); // 获取绘制文本时光笔所需的偏移量
            CGContextSetTextPosition(context, penOffset, lineOrigin.y); // 设置每一行位置
            CTLineDraw(line, context); // 绘制每一行的内容
            
            // 从CTLine中获取所有的CTRun:
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            long runCounts = CFArrayGetCount(runs);
            
            // 遍历CTLine中的每一个CTRun:
            for (int j = 0; j < runCounts; j++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                
                /*
                 CFDictionaryRef attributes = CTRunGetAttributes(run);
                 */
                
                /*
                 void CTRunDraw(CTRunRef run, CGContextRef context, CFRange range)
                 
                 range: The range of glyphs to be drawn, with the entire range having a  location of 0 and a length of CTRunGetGlyphCount. If the length of the range is set to 0, then the operation will continue from the range's start index to the end of the run.
                 */
                
                /*
                 CTRunDraw(run, context, CFRangeMake(0, 0));    // 绘制每一个run的内容
                 */
                
                NSDictionary *runAttributes = (__bridge NSDictionary *)CTRunGetAttributes(run);
                CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
                if (delegate) {
                    // 绘制附件的内容:
                    [self drawAttachmentContentInContext:context
                                                 ctframe:ctFrame
                                                    line:line
                                              lineOrigin:lineOrigin
                                                     run:run
                                                delegate:delegate
                                               wordSpace:wordSpace];
                }
                else {
                    // 保存高亮文案在字符中的NSRange以及在CTFrame中的CGRect (以便在label中处理点击事件):
                    if (isSave) {
                        CGFloat contentHeight = size.height;
                        int result = [self saveHighlightRangeAndFrame:line
                                                           lineOrigin:lineOrigin
                                                            lineIndex:lineIndex
                                                           lineHeight:lineHeight
                                                                  run:run
                                                        ContentHeight:contentHeight
                                                     attributedString:attributedString
                                                                check:check];
                        if (result == -1) {
                            if (cancel) {
                                cancel();
                            }
                            
                            CFRelease(drawPath);
                            CFRelease(ctFrame);
                            CFRelease(ctFramesetter);
                            
                            return -1;
                        }
                    }
                }
            }
        }
        
        CFRelease(drawPath);
        CFRelease(ctFrame);
        CFRelease(ctFramesetter);
    }
    
    return 0;
}


#pragma mark - Private Methods -
- (void)drawAttachmentContentInContext:(CGContextRef)context
                               ctframe:(CTFrameRef)ctFrame
                                  line:(CTLineRef)line
                            lineOrigin:(CGPoint)lineOrigin
                                   run:(CTRunRef)run
                              delegate:(CTRunDelegateRef)delegate
                             wordSpace:(CGFloat)wordSpace {
    QATextRunDelegate *runDelegate = CTRunDelegateGetRefCon(delegate);
    if ([runDelegate isKindOfClass:[QATextRunDelegate class]]) {
        id attachmentContent = runDelegate.attachmentContent;
        if (attachmentContent) {
            if ([attachmentContent isKindOfClass:[UIImage class]]) { // 绘制自定义的Emoji表情
                UIImage *image = (UIImage *)attachmentContent;
                
                // 获取当前CTRun的CGSize:
                CGRect runBounds;
                CGFloat ascent;
                CGFloat descent;
                CGFloat leading;
                {
                    runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading) - wordSpace; // kCTTextAlignmentJustified对齐方式会影响到runBounds.size.width的值
                    runBounds.size.width = runDelegate.width - wordSpace;
                    runBounds.size.height = ascent + descent;
                }
                
                // 获取当前CTRun的CGPoint:
                {
                    CGPoint runPosition = CGPointZero;
                    CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
                    // NSLog(@" runPosition : %@",NSStringFromCGPoint(runPosition));
                    
                    runBounds.origin.x = lineOrigin.x + runPosition.x;
                    runBounds.origin.y = lineOrigin.y;
                    runBounds.origin.y -= descent;
                    
                    // CGFloat offsetX = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                    // NSLog(@"   offsetX : %lf",offsetX);
                }
                
                CGPathRef pathRef = CTFrameGetPath(ctFrame);
                CGRect boundingBox = CGPathGetBoundingBox(pathRef);
                CGRect delegateRect = CGRectOffset(runBounds, boundingBox.origin.x, boundingBox.origin.y);
                
                CGContextDrawImage(context, delegateRect, image.CGImage);  // 绘制image
            }
            else {    // 绘制自定义的其它控件
                /**
                 ......
                 ......
                 */
            }
        }
        else {
            NSLog(@"runDelegate设置有误!");
        }
    }
}
- (int)saveHighlightRangeAndFrame:(CTLineRef)line
                       lineOrigin:(CGPoint)lineOrigin
                        lineIndex:(CFIndex)lineIndex
                       lineHeight:(CGFloat)lineHeight
                              run:(CTRunRef)run
                    ContentHeight:(CGFloat)contentHeight
                 attributedString:(NSMutableAttributedString *)attributedString
                            check:(BOOL(^)(NSString *content))check {
    if (!_saveDoneDic) {
        _saveDoneDic = [NSMutableDictionary dictionary];
    }
    CFRange runRange = CTRunGetStringRange(run);
    NSRange currentRunRange = NSMakeRange(runRange.location, runRange.length);
    NSLog(@"currentRunRange: %@",NSStringFromRange(currentRunRange));
    NSString *runContent = [attributedString.string substringWithRange:currentRunRange];
    NSMutableString *currentRunString = [NSMutableString stringWithString:runContent];
    NSLog(@"currentRunString【 BEGIN 】: %@",currentRunString);
    
    for (int i = 0; i < self.highlightRanges.count; i++) {
        NSString *rangeString = [self.highlightRanges objectAtIndex:i];
        CGFloat runAscent, runDescent, runLeading;
        NSRange highlightRange = NSRangeFromString(rangeString);  // 存放高亮文本的range
        NSLog(@" ");
        NSLog(@"【 循环-当前highlightRange 】: %@",NSStringFromRange(highlightRange));
        
        // 找出highlightRange与currentRunRange的重合位置:
        NSRange overlappingRange = NSIntersectionRange(highlightRange, currentRunRange);
        if (overlappingRange.length > 0) {
            CGFloat offsetX = CTLineGetOffsetForStringIndex(line, runRange.location, NULL);
            
            // 获取高亮文案:
            NSString *highlightText = [self.textDic valueForKey:rangeString];
            NSLog(@"highlightText: %@",highlightText);
            if (!highlightText || highlightText.length == 0) {
                continue;
            }
            
            /**
             textNewlineDic中使用
             保存某个attributedString的某个highlightText在绘制过程中的换行信息
             textNewlineDic的值是个数组、数组中元素的个数代表highlightText在绘制过程中所占用的行数
             */
            NSString *keyString = [NSString stringWithFormat:@"%@%@", attributedString.string, highlightText];
            NSString *encodedKey = [keyString md5Hash];
            
            // 异常处理:
            if (check && check(attributedString.string)) {
                return -1;
            }
            
            // 保存高亮文案的CGRect & 以及文案的换行信息:
            if (highlightRange.location == currentRunRange.location &&
                highlightRange.length == currentRunRange.length) {
                // 获取高亮文案的Rect:
                CGRect runRect;
                runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, &runLeading);
                runRect.origin.x = lineOrigin.x + offsetX;
                runRect.origin.y = lineOrigin.y - runDescent;
                runRect.size.height = lineHeight;
                CGAffineTransform transform = CGAffineTransformMakeTranslation(0, contentHeight);
                transform = CGAffineTransformScale(transform, 1.f, -1.f);
                CGRect highlightRect = CGRectApplyAffineTransform(runRect, transform);
                
                [self saveHighlightRect:highlightRect
                          highlightText:highlightText
                     withHighlightRange:highlightRange
                             encodedKey:encodedKey];
                
                currentRunString = nil;
            }
            else {
                NSInteger length_previous = 0;
                if (i > 0) {  // 查看之前的高亮文案是否已被完整的保存
                    int position = i - 1;
                    NSString *rangeString_previous = [self.highlightRanges objectAtIndex:position];
                    NSRange highlightRange_previous = NSRangeFromString(rangeString_previous);
                    NSString *highlightText_previous = [self.textDic valueForKey:rangeString_previous];
                    NSString *highlightText_previous_saved = [_saveDoneDic valueForKey:rangeString_previous];
                    NSLog(@"highlightText_previous_saved: %@",highlightText_previous_saved);
                    if (highlightText_previous_saved) {
                        length_previous = highlightText_previous.length - highlightText_previous_saved.length;
                        NSRange subRange = NSMakeRange(0, length_previous);
                        NSString *subString = [currentRunString substringWithRange:subRange];
                        NSLog(@"subString 【 0 】: %@",subString);
                        
                        // 获取高亮文案的Rect:
                        CGRect runRect;
                        runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(subRange.location, subRange.length), &runAscent, &runDescent, &runLeading);
                        runRect.origin.x = lineOrigin.x + offsetX;
                        runRect.origin.y = lineOrigin.y - runDescent;
                        runRect.size.height = lineHeight;
                        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, contentHeight);
                        transform = CGAffineTransformScale(transform, 1.f, -1.f);
                        CGRect highlightRect_previous = CGRectApplyAffineTransform(runRect, transform);
                        NSLog(@"highlightRect_previous【0】: %@",NSStringFromCGRect(highlightRect_previous));

                        [self saveHighlightRect:highlightRect_previous
                                  highlightText:subString
                             withHighlightRange:highlightRange_previous
                                     encodedKey:[_saveDoneDic valueForKey:@"encodedKey"]];
                        
                        [currentRunString deleteCharactersInRange:subRange];
                        NSLog(@"currentRunString【 END - 0 】: %@",currentRunString);
                        
                        NSInteger current_highlightText_previous_totalLength = highlightText_previous_saved.length + subString.length;
                        if (current_highlightText_previous_totalLength == highlightText_previous.length) {
                            [_saveDoneDic removeObjectForKey:rangeString_previous];
                            [_saveDoneDic removeObjectForKey:@"encodedKey"];
                        }
                    }
                }

                NSRange subRange = NSMakeRange(0, overlappingRange.length - length_previous);
                while ([highlightText containsString:currentRunString]) {
                    NSString *subString = [currentRunString substringWithRange:subRange];
                    NSLog(@"subString 【 1 】: %@",subString);
                    
                    // 获取高亮文案的Rect:
                    CGRect runRect;
                    runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(subRange.location, subRange.length), &runAscent, &runDescent, &runLeading);
                    runRect.origin.x = lineOrigin.x + offsetX;
                    runRect.origin.y = lineOrigin.y - runDescent;
                    runRect.size.height = lineHeight;
                    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, contentHeight);
                    transform = CGAffineTransformScale(transform, 1.f, -1.f);
                    CGRect highlightRect = CGRectApplyAffineTransform(runRect, transform);
                    NSLog(@"highlightRect【1】: %@",NSStringFromCGRect(highlightRect));

                    [self saveHighlightRect:highlightRect
                              highlightText:subString
                         withHighlightRange:highlightRange
                                 encodedKey:encodedKey];
                    
                    if (subString.length < highlightText.length) {
                        [_saveDoneDic setValue:subString forKey:NSStringFromRange(highlightRange)];
                        [_saveDoneDic setValue:encodedKey forKey:@"encodedKey"];
                    }
                    else if (subString.length == highlightText.length) {
                        [_saveDoneDic removeObjectForKey:NSStringFromRange(highlightRange)];
                        [_saveDoneDic removeObjectForKey:@"encodedKey"];
                    }
                    
                    NSInteger length = currentRunString.length - subRange.length;
                    [currentRunString deleteCharactersInRange:subRange];
                    NSLog(@"currentRunString【 END - 1 】: %@",currentRunString);
                    subRange = NSMakeRange(0, length);
                    if (currentRunString.length == 0) {
                        break;
                    }
                }
            }
            if (!currentRunString || currentRunString.length == 0) {
                break;
            }
        }
    }
    
    NSLog(@"self.highlightFrameDic: %@",self.highlightFrameDic);
    NSLog(@"self.textNewlineDic: %@",self.textNewlineDic);
    NSLog(@" ");
    
    return 0;
}
- (void)saveHighlightRect:(CGRect)highlightRect
            highlightText:(NSString *)highlightText
       withHighlightRange:(NSRange)highlightRange
               encodedKey:(NSString *)encodedKey {
    NSMutableArray *highlightRects = [self.highlightFrameDic valueForKey:NSStringFromRange(highlightRange)];
    if (!highlightRects) {
        highlightRects = [NSMutableArray array];
    }
    NSMutableArray *newlineTexts = [self.textNewlineDic valueForKey:encodedKey];
    if (!newlineTexts) {
        newlineTexts = [NSMutableArray array];
    }
    
    if (highlightRects.count > 0) {
        NSValue *value = [highlightRects lastObject];
        CGRect rect = value.CGRectValue;
        if (fabs(highlightRect.origin.y - rect.origin.y) <= 0.1 ) {  // 仍处在同一line里
            CGRect newRect = CGRectMake(rect.origin.x, highlightRect.origin.y, (rect.size.width + highlightRect.size.width), highlightRect.size.height);
            [highlightRects replaceObjectAtIndex:(highlightRects.count-1) withObject:[NSValue valueWithCGRect:newRect]];
        }
        else {
            [highlightRects addObject:[NSValue valueWithCGRect:highlightRect]];
            [newlineTexts addObject:highlightText];
        }
    }
    else {
        [highlightRects addObject:[NSValue valueWithCGRect:highlightRect]];
        [newlineTexts addObject:highlightText];
    }
    [self.highlightFrameDic setValue:highlightRects forKey:NSStringFromRange(highlightRange)];
    [self.textNewlineDic setValue:newlineTexts forKey:encodedKey];
}


//#pragma mark - Property -
//- (void)setCtFrame:(CTFrameRef)ctFrame {
//    if (_ctFrame != ctFrame) {
//        if (_ctFrame != nil) {
//            CFRelease(_ctFrame);
//        }
//        if (ctFrame) {
//            CFRetain(ctFrame);
//        }
//        _ctFrame = ctFrame;
//    }
//}

@end


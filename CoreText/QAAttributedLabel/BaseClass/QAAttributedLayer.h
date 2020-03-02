//
//  QAAttributedLayer.h
//  CoreText
//
//  Created by Avery on 2018/12/11.
//  Copyright © 2018年 Avery. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <stdatomic.h>
@class QAAttributedLabel, QATextDrawer;


static dispatch_queue_t _Nonnull QAAttributedLayerDrawQueue() {
#define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static atomic_int counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t queue_attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                queues[i] = dispatch_queue_create("com.avery.QAAttributedLayer.render", queue_attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.avery.QAAttributedLayer.render", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            }
        }
    });
    
    // 线程安全的自增计数,每调用一次+1
    atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
    return queues[(counter) % queueCount];
#undef MAX_QUEUE_COUNT
}


@interface QAAttributedLayer : CALayer

@property (nonatomic, nullable) __block id currentCGImage;
@property (nonatomic, copy, nullable) NSDictionary *truncationInfo;
@property (nonatomic, strong, nullable) NSMutableAttributedString *renderText;

- (void)backUpAttributedString:(NSMutableAttributedString * _Nonnull)attributedString;

- (void)getDrawAttributedTextWithLabel:(QAAttributedLabel * _Nonnull)attributedLabel
                            selfBounds:(CGRect)bounds
                   checkAttributedText:(BOOL(^_Nullable)(NSString * _Nonnull))checkBlock
                            completion:(void(^_Nullable)(id _Nonnull))completion;

/**
 获取文案所对应的AttributedString并保存相关的属性
 */
- (NSMutableAttributedString * _Nullable)getAttributedStringWithString:(NSString * _Nonnull)content
                                                              maxWidth:(CGFloat)maxWidth;

- (int)beginDrawAttributedText:(id _Nonnull)attributedTextObj
                         label:(QAAttributedLabel * _Nonnull)attributedLabel
                    selfBounds:(CGRect)bounds
                       context:(CGContextRef _Nonnull)context
           checkAttributedText:(BOOL(^_Nullable)(NSString *_Nonnull content))checkBlock;


/**
 文案的绘制
 */
- (int)drawAttributedString:(NSMutableAttributedString * _Nonnull)attributedText
                    context:(CGContextRef _Nonnull)context
                contentSize:(CGSize)contentSize
                  wordSpace:(NSInteger)wordSpace
              numberOfLines:(NSInteger)numberOfLines
              textAlignment:(NSTextAlignment)textAlignment
          saveHighlightText:(BOOL)saveHighlightText
                  justified:(BOOL)justified;


- (void)getAttributedString:(NSMutableAttributedString * _Nullable __strong * _Nullable)attributedText
          highlightContents:(NSMutableDictionary * _Nullable __strong * _Nullable)highlightContents
            highlightRanges:(NSMutableDictionary * _Nullable __strong * _Nullable)highlightRanges
                withContent:(NSString * _Nonnull)content;

- (void)processDiyEmojiText:(NSMutableAttributedString * _Nonnull)attributedText
                      label:(QAAttributedLabel * _Nonnull)attributedLabel
          highlightContents:(NSMutableDictionary * _Nonnull)highlightContents
            highlightRanges:(NSMutableDictionary * _Nonnull)highlightRanges;

- (void)setSetedHighlightTexts:(NSMutableAttributedString * _Nonnull)attributedText
                         label:(QAAttributedLabel * _Nonnull)attributedLabel;

- (void)setHighlightTexts:(NSMutableAttributedString * _Nonnull)attributedText
          highlightRanges:(NSMutableDictionary * _Nonnull)highlightRanges;

- (void)processSeeMoreText:(NSMutableAttributedString *_Nullable __strong * _Nullable)attributedText
                     label:(QAAttributedLabel * _Nonnull)attributedLabel
                  maxWidth:(CGFloat)maxWidth
         highlightContents:(NSMutableDictionary * _Nonnull)highlightContents
           highlightRanges:(NSMutableDictionary * _Nonnull)highlightRanges;

- (void)saveAttributedTextInfo:(NSMutableAttributedString * _Nonnull)attributedText
             highlightContents:(NSMutableDictionary * _Nonnull)highlightContents
               highlightRanges:(NSMutableDictionary * _Nonnull)highlightRanges
                         label:(QAAttributedLabel * _Nonnull)attributedLabel;

- (int)updateAttributeText:(NSMutableAttributedString *)attributedText
      withTextColor:(UIColor *)textColor
textBackgroundColor:(UIColor *)textBackgroundColor
                     range:(NSRange)range;

- (int)saveHighlightRanges:(NSMutableDictionary *)highlightRanges
highlightContents:(NSMutableDictionary *)highlightContents
   truncationInfo:(NSDictionary *)truncationInfo
  attributedLabel:(QAAttributedLabel *)attributedLabel
          attributedString:(NSMutableAttributedString *)attributedText;

/**
 针对range处的text进行高亮绘制
 */
- (void)drawHighlightColor:(NSRange)range highlightRects:(NSArray *)highlightRects;

/**
 针对ranges处的text批量进行高亮绘制 (SearchText使用)
 */
- (void)drawHighlightColorWithSearchRanges:(NSArray * _Nonnull)ranges
                             attributeInfo:(NSDictionary * _Nonnull)info
                        inAttributedString:(NSMutableAttributedString * _Nonnull)attributedText;

/**
 清除range处的text的高亮状态
 */
- (void)clearHighlightColor:(NSRange)range;

/**
 label中调用"setContentsImage:attributedString:"的时候使用
 */
- (void)drawTextBackgroundWithAttributedString:(NSMutableAttributedString * _Nonnull)attributedString;

@end

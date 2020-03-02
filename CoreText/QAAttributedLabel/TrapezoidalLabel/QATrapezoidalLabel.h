//
//  QATrapezoidalLabel.h
//  CoreText
//
//  Created by Avery An on 2020/2/27.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QAAttributedLabel.h"

@class QATrapezoidalLayer;

NS_ASSUME_NONNULL_BEGIN

@interface QATrapezoidalLabel : QAAttributedLabel

/**
 设置此属性时、文案将会全部被展示、不会去做文案的截断等操作(即:视numberOfLines的值为0)
 */
@property (nonatomic, copy, nullable) NSArray *trapezoidalTexts;
@property (nonatomic, assign) NSInteger trapezoidalLineHeight;   // 行高

@end

NS_ASSUME_NONNULL_END

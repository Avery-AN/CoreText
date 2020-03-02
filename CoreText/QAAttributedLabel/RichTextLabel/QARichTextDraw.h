//
//  QARichTextDraw.h
//  CoreText
//
//  Created by Avery An on 2020/2/27.
//  Copyright © 2020 Avery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QATextDraw.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (QARichTextDraw)

- (int)drawAttributedTextWithContext:(CGContextRef)context
                         contentSize:(CGSize)contentSize
                           wordSpace:(CGFloat)wordSpace
                    maxNumberOfLines:(NSInteger)maxNumberOfLines
                       textAlignment:(NSTextAlignment)textAlignment
                   saveHighlightText:(BOOL)saveHighlightText
                           justified:(BOOL)justified;
@end

NS_ASSUME_NONNULL_END

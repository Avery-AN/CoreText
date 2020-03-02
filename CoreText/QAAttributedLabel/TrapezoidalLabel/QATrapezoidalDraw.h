//
//  QATrapezoidalDraw.h
//  CoreText
//
//  Created by Avery An on 2020/2/27.
//  Copyright © 2020 Avery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QATextDraw.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (QATrapezoidalDraw)

- (int)drawWithTrapezoidalLineHeight:(NSInteger)trapezoidalLineHeight
      contentSize:(CGSize)contentSize
        wordSpace:(CGFloat)wordSpace
        textAlignment:(NSTextAlignment)textAlignment
          leftGap:(CGFloat)leftGap
         rightGap:(CGFloat)rightGap
          context:(CGContextRef)context
            lines:(NSArray *)lines
saveHighlightText:(BOOL)saveHighlightText;

@end

NS_ASSUME_NONNULL_END

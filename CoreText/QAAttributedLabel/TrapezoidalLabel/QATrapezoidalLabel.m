//
//  QATrapezoidalLabel.m
//  CoreText
//
//  Created by Avery An on 2020/2/27.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QATrapezoidalLabel.h"
#import "QATrapezoidalLayer.h"

@implementation QATrapezoidalLabel

#pragma mark - Override Methods -
+ (Class)layerClass {
    return [QATrapezoidalLayer class];
}

- (void)setTrapezoidalTexts:(NSArray *)trapezoidalTexts {
    _trapezoidalTexts = [trapezoidalTexts copy];
    self.numberOfLines = 0;
    [self performSelector:@selector(_commitUpdate)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

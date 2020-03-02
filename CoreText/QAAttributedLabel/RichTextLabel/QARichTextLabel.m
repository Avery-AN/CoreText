//
//  QARichTextLabel.m
//  CoreText
//
//  Created by Avery An on 2020/2/27.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "QARichTextLabel.h"
#import "QARichTextLayer.h"

@implementation QARichTextLabel

#pragma mark - Override Methods -
+ (Class)layerClass {
    return [QARichTextLayer class];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

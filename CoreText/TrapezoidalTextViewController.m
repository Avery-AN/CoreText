//
//  TrapezoidalTextViewController.m
//  CoreText
//
//  Created by Avery An on 2020/2/28.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "TrapezoidalTextViewController.h"
#import "QATrapezoidalLabel.h"

@interface TrapezoidalTextViewController ()
@property(nonatomic) QATrapezoidalLabel *label;
@end

@implementation TrapezoidalTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    NSMutableArray *texts = [NSMutableArray array];
    [texts addObject:@"这里是另外一种样式的Label"];
    [texts addObject:@"Tiktok-Label😃"];
    [texts addObject:@"测试其#圆角弧度#的背景"];
    
    QATrapezoidalLabel *label = [[QATrapezoidalLabel alloc] initWithFrame:CGRectMake(10, 120, 390, 260)];
    self.label = label;
    label.backgroundColor = [UIColor grayColor];
    label.lineBackgroundColor = [UIColor orangeColor];
    label.trapezoidalTexts = texts;
    label.trapezoidalLineHeight = 50;
    label.wordSpace = 3;
    // label.highlightTextBackgroundColor = [UIColor yellowColor];
    label.font = [UIFont fontWithName:@"PingFangTC-Regular" size:26];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.highLightTexts = [NSArray arrayWithObject:@"Tiktok"];
    label.highlightTextColor = [UIColor purpleColor];
    label.highlightTapedTextColor = [UIColor greenColor];
    label.highlightTapedBackgroundColor = [UIColor lightGrayColor];
    label.highlightAtTextColor = [UIColor greenColor];
    label.highlightLinkTextColor = [UIColor orangeColor];
    label.highlightTopicTextColor = [UIColor blueColor];
    label.highlightAtTapedTextColor = [UIColor redColor];
    label.highlightLinkTapedTextColor = [UIColor magentaColor];
    label.highlightTopicTapedTextColor = [UIColor redColor];
    label.atHighlight = YES;
    label.topicHighlight = YES;
    [self.view addSubview:label];
    
    label.QAAttributedLabelTapAction = ^(NSString * _Nullable content, QAAttributedLabel_TapedStyle style) {
         NSLog(@"   点击高亮文案 style: %ld; content: %@", style, content);
    };
    
    
    
    {  // <自适应高度>按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor orangeColor];
        button.frame = CGRectMake(100, 600, [UIScreen mainScreen].bounds.size.width - 100*2, 50);
        [button setTitle:@"自适应高度" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(action_sizeToFit) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}


#pragma mark - Actions -
- (void)action_sizeToFit {
    [self.label sizeToFit];
}

@end

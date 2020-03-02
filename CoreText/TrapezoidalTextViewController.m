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

@end

@implementation TrapezoidalTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    NSMutableArray *texts = [NSMutableArray array];
    [texts addObject:@"我在模仿Tiktok-Label"];
    [texts addObject:@"你知不知道"];
    [texts addObject:@"你品你细品哈哈😃"];
    
    QATrapezoidalLabel *label = [[QATrapezoidalLabel alloc] initWithFrame:CGRectMake(10, 120, 390, 660)];
    label.backgroundColor = [UIColor grayColor];
    label.trapezoidalTexts = texts;
    label.trapezoidalLineHeight = 50;
    label.highlightTextBackgroundColor = [UIColor orangeColor];
    label.font = [UIFont fontWithName:@"PingFangTC-Regular" size:30];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

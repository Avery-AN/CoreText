//
//  RootViewController.m
//  CoreText
//
//  Created by Avery An on 2019/11/17.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "RootViewController.h"
#import "RichTextViewController.h"
#import "TrapezoidalTextViewController.h"

@implementation RootViewController

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor orangeColor];
    button.frame = CGRectMake(100, 120, [UIScreen mainScreen].bounds.size.width - 100*2, 50);
    [button setTitle:@"RichText" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(richTextAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    UIButton *button_2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button_2.backgroundColor = [UIColor orangeColor];
    button_2.frame = CGRectMake(100, 200, [UIScreen mainScreen].bounds.size.width - 100*2, 50);
    [button_2 setTitle:@"TrapezoidalText" forState:UIControlStateNormal];
    [button_2 addTarget:self action:@selector(trapezoidalAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_2];
}


#pragma mark - Actions -
- (void)richTextAction {
    RichTextViewController *vc = [RichTextViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)trapezoidalAction {
    TrapezoidalTextViewController *vc = [TrapezoidalTextViewController new];
    [self.navigationController pushViewController:vc animated:YES];
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

//
//  RootViewController.m
//  CoreText
//
//  Created by Avery An on 2019/11/17.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "RootViewController.h"
#import "QAAttributedLabel.h"

@interface RootViewController ()
@property (nonatomic) QAAttributedLabel *label;
@end

@implementation RootViewController

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor orangeColor];
    button.frame = CGRectMake(100, 500, [UIScreen mainScreen].bounds.size.width - 100*2, 50);
    [button setTitle:@"SizeToFit" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(action_sizeToFit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    
    // 【 QAAttributedLabel的使用方法 】
    QAAttributedLabel *label = [[QAAttributedLabel alloc] initWithFrame:CGRectMake(10, 90, [UIScreen mainScreen].bounds.size.width- 10*2, 400)];
    self.label = label;
    label.backgroundColor = [UIColor grayColor];
    label.font = [UIFont fontWithName:@"PingFangTC-Regular" size:19];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentJustified;
    //label.textAlignment = NSTextAlignmentLeft;
    //label.lineBreakMode = NSLineBreakByCharWrapping;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = @"[nezha][nezha][nezha][nezha][nezha]#注意啦#当我们在Cell上添加系统控件的时候，实质上系统都需要调用底层的接口进行绘制，当我们大量添加控件时，对资源的开销也会是很大的，所以我们可以索性直接绘制，提高效率。[nezha][nezha][nezha][nezha][nezha][nezha][nezha][nezha]@AveryAN:本例中的Label在tableView中的使用详见:https://github.com/Avery-AN/TableView";
    
    
    // *** 【0】是否需要进行异步绘制:
    {
        label.display_async = YES;
    }
    
    // *** 【1】 段落样式:
    {
        label.lineSpace = 1;
        label.wordSpace = 6;
        //label.paragraphSpace = 30;
    }
    
    
    // *** 【2】 文案的 '@' & 'url' & 'Topic' 高亮:
    {
        label.linkHighlight = YES;
        label.atHighlight = YES;
        label.topicHighlight = YES;
        label.showShortLink = YES;
        label.shortLink = @"网页短链接";
        // label.highlightFont = [UIFont systemFontOfSize:22];

        label.highLightTexts = [NSArray arrayWithObjects:@"调用底层的接口进行绘制", nil];
        label.highlightTextColor = [UIColor purpleColor];
        label.highlightTapedTextColor = [UIColor greenColor];
        // label.highlightTapedBackgroundColor = [UIColor yellowColor];
        label.highlightAtTextColor = [UIColor greenColor];
        label.highlightLinkTextColor = [UIColor orangeColor];
        label.highlightTopicTextColor = [UIColor redColor];
        label.highlightAtTapedTextColor = [UIColor redColor];
        label.highlightLinkTapedTextColor = [UIColor magentaColor];
        label.highlightTopicTapedTextColor = [UIColor greenColor];
        // label.highlightTextBackgroundColor = [UIColor brownColor];
    }
    
    
    // *** 【3】 文案的裁剪 ('...全文'):
    {
        label.numberOfLines = 0;
        
//        label.numberOfLines = 6;
//        label.showMoreText = YES;
//        label.seeMoreText = @"...全文";
//        label.moreTextFont = [UIFont fontWithName:@"PingFangTC-Regular" size:19];
//        label.moreTextColor = [UIColor whiteColor];
//        label.moreTextBackgroundColor = [UIColor purpleColor];
//        label.moreTapedBackgroundColor = [UIColor redColor];
//        label.moreTapedTextColor = [UIColor blueColor];
    }
    
    [self.view addSubview:label];
    
    [self performSelector:@selector(searchText:) withObject:@"直接绘制" afterDelay:1];
    
    label.QAAttributedLabelTapAction = ^(NSString * _Nullable content, QAAttributedLabel_TapedStyle style) {
        NSLog(@"   点击高亮文案 style: %ld; content: %@", style, content);
    };
}



#pragma mark - Action -
- (void)action_sizeToFit {
    [self.label sizeToFit];
}
- (void)searchText:(NSString *)text {
    [self.label searchTexts:[NSArray arrayWithObject:text]
      resetSearchResultInfo:^NSDictionary * _Nullable{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[UIColor whiteColor] forKey:@"textColor"];
        [dic setValue:[UIColor orangeColor] forKey:@"textBackgroundColor"];
        return dic;
    }];
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
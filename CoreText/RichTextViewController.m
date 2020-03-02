//
//  RichTextViewController.m
//  CoreText
//
//  Created by Avery An on 2020/2/28.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "RichTextViewController.h"
#import "QARichTextLabel.h"

@interface RichTextViewController ()
@property (nonatomic) QARichTextLabel *label;
@end

@implementation RichTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor whiteColor];
        
        
        {  // <自适应高度>按钮
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor orangeColor];
            button.frame = CGRectMake(100, 600, [UIScreen mainScreen].bounds.size.width - 100*2, 50);
            [button setTitle:@"自适应高度" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(action_sizeToFit) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
        }
        
        
        
        // 【 QAAttributedLabel的使用方法 】
        QARichTextLabel *label = [[QARichTextLabel alloc] initWithFrame:CGRectMake(10, 90, 388, 490)];
    NSLog(@"label-width: %f",label.bounds.size.width);
        [self.view addSubview:label];
        self.label = label;
        label.backgroundColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:18]; //[UIFont fontWithName:@"PingFangTC-Regular" size:20];
//    label.highlightFont = [UIFont fontWithName:@"PingFangTC-Regular" size:30];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentJustified;
//        label.textAlignment = NSTextAlignmentLeft;
        //label.lineBreakMode = NSLineBreakByCharWrapping;
        label.lineBreakMode = NSLineBreakByWordWrapping;  // [nezha][nezha][nezha][nezha][nezha]
        NSString *content = @"【1】#注意啦#我们在Cell上添加系统控件的时候，实质上系统都需要调用底层的接口进行绘制，当我们大量添加控件时，对资源的开销也是很大的，所以我们可以直接绘制,[nezha][nezha][nezha][nezha][nezha][nezha][nezha][nezha][nezha]提高效率。你猜到底是不是这样的呢？https://github.com/Avery-AN哈哈哈哈哈哈哈 - 1；[nezha][nezha][nezha][nezha]滑动时按需加载，这个在大量图片展示，网络加载的时候很管用！@Avery-AN（SDWebImage已经实现异步加载，配合这条性能杠杠的）。对象的调整也经常是消耗 CPU 资源的地方。@这里是另外的一个需要注意的地方 CALayer:CALayer 内部并没有属性，当调用属性方法时，它内部是通过运行时 resolveInstanceMethod 为对象临时添加一个方法，哈哈哈😁❄️🌧🐟🌹@这是另外的一个人、并把对应属性值保存到内部的一个 Dictionary 里，同时还会通知 delegate、创建动画等等，非常消耗资源。UIView 的关于显示相关的属性（比如 frame/bounds/transform）等实际上都是 CALayer 属性映射来的，所以对 UIView 的这些属性进行调整时，消耗的资源要远大于一般的属性。对此你在应用中，应该尽量减少不必要的属性修改。";
        label.text = content;
        
        // *** 【0】是否需要进行异步绘制:
        {
            label.display_async = YES;
        }
        
        // *** 【1】 段落样式:
        {
            label.lineSpace = 1.1;
            label.wordSpace = 3;
            //label.paragraphSpace = 30;
        }
        
        
        // *** 【2】 文案的 '@' & 'url' & 'Topic' 高亮:
        {
            label.linkHighlight = YES;
            label.atHighlight = YES;
            label.topicHighlight = YES;
//            label.showShortLink = YES;
//            label.shortLink = @"网页短链接";
            // label.highlightFont = [UIFont systemFontOfSize:29];

            label.highLightTexts = [NSArray arrayWithObjects:@"大量添加控件",@"直接绘制", nil];
            label.highlightTextColor = [UIColor purpleColor];
            label.highlightTapedTextColor = [UIColor greenColor];
            // label.highlightTapedBackgroundColor = [UIColor yellowColor];
            label.highlightAtTextColor = [UIColor greenColor];
            label.highlightLinkTextColor = [UIColor orangeColor];
            label.highlightTopicTextColor = [UIColor blueColor];
            label.highlightAtTapedTextColor = [UIColor blueColor];
            label.highlightLinkTapedTextColor = [UIColor magentaColor];
            label.highlightTopicTapedTextColor = [UIColor redColor];
            // label.highlightTextBackgroundColor = [UIColor brownColor];
        }
        
        
        // *** 【3】 超长文案末尾处的裁剪 ('...全文'):
        {
    //        label.numberOfLines = 0;
            
            label.numberOfLines = 21;
            label.showMoreText = YES;
            label.seeMoreText = @"...全文";
//            label.moreTextFont = [UIFont fontWithName:@"PingFangTC-Regular" size:36];
            label.moreTextColor = [UIColor yellowColor];
    //        label.moreTextBackgroundColor = [UIColor purpleColor];
    //        label.moreTapedBackgroundColor = [UIColor redColor];
            label.moreTapedTextColor = [UIColor blueColor];
        }
        
        
        // 需要等label渲染完毕后再进行搜索:
    //    [self performSelector:@selector(searchText:) withObject:@"直接绘制" afterDelay:1];
        
        label.QAAttributedLabelTapAction = ^(NSString * _Nullable content, QAAttributedLabel_TapedStyle style) {
            NSLog(@"   点击高亮文案 style: %ld; content: %@", style, content);
        };
        
        
        
        
    //
    //     // 测试代码:
    //     {
    ////         UIView *view = [[UIView alloc] initWithFrame:CGRectMake(30, 180, 100, 100)];
    ////         view.backgroundColor = [UIColor blueColor];
    ////         [self.view addSubview:view];
    ////
    ////         [UIView animateWithDuration:5 animations:^{
    ////             view.frame = CGRectMake(260, 660, 100, 100);
    ////         }];
    //
    //         [label performSelector:@selector(setTextColor:) withObject:[UIColor lightGrayColor] afterDelay:1.3];
    //         [label performSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:21] afterDelay:1.3];
    //
    //         [label performSelector:@selector(setTextColor:) withObject:[UIColor cyanColor] afterDelay:1.8];
    //         [label performSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:25] afterDelay:1.8];
    //
    //         [label performSelector:@selector(setHighlightFont:) withObject:[UIFont systemFontOfSize:39] afterDelay:2.2];
    //
    //         [label performSelector:@selector(setTextColor:) withObject:[UIColor redColor] afterDelay:2.5];
    //
    ////         [self performSelector:@selector(testMethod) withObject:nil afterDelay:2];
    //     }

}


//- (void)testMethod {
//    self.label.font = [UIFont systemFontOfSize:16];
//    self.label.highlightFont = [UIFont systemFontOfSize:26];
//    self.label.textColor = [UIColor orangeColor];
//}



#pragma mark - Actions -
- (void)action_sizeToFit {
    [self.label sizeToFit];
}
- (void)searchText:(NSString *)text {
    [self.label searchTexts:[NSArray arrayWithObject:text]
      resetSearchResultInfo:^NSDictionary * _Nullable {
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

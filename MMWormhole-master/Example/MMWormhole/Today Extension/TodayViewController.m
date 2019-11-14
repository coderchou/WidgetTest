//
//  TodayViewController.m
//  Today Extension
//
//  Created by Conrad Stoll on 12/10/14.
//  Copyright (c) 2014 Conrad Stoll. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import "MMWormhole.h"

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) MMWormhole *wormhole;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (nonatomic, strong) UIButton *entryBtn;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.coderchou.wormhole"
                                                         optionalDirectory:@"wormhole"];
    
    __weak typeof (self) weakSelf = self;
    [self.wormhole listenForMessageWithIdentifier:@"selection" listener:^(id  _Nullable messageObject) {
        [weakSelf showMsg:messageObject];
        NSLog(@"接收到 main app消息%@",messageObject);
    }];
    
    [self.view insertSubview:self.entryBtn atIndex:0];
}



- (void)showMsg:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        self.msgLabel.text = [dict valueForKey:@"selectionString"];;
    }
//    [self.traditionalWormhole passMessageObject:@{@"selectionString" : title} identifier:@"selection"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    
//    self.view.backgroundColor = [UIColor orangeColor];
    self.preferredContentSize = CGSizeMake(320.0f, 500.0f);
    NSDictionary *dict = [self.wormhole messageWithIdentifier:@"selection"];
    self.msgLabel.text = [dict valueForKey:@"selectionString"];
    
    self.entryBtn.frame = CGRectMake(10, 30, 80, 80);
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {

    
    NSLog(@"数据更新");
    //这个方法比 viewWillAppear 先调用
    completionHandler(NCUpdateResultNewData);
    
}


- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    NSLog(@"widgetActiveDisplayModeDidChange : %@" ,activeDisplayMode==NCWidgetDisplayModeCompact ? @"固定高" : @"可变高");
}
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    NSLog(@"%@",@"widgetMarginInsetsForProposedMarginInsets");
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

// Pass messages each time a button is tapped using the identifier button
// The messages contain a single number value with the buttonNumber key
- (IBAction)didTapOne:(id)sender {
    [self.wormhole passMessageObject:@{@"buttonNumber" : @(1)} identifier:@"button"];
}

- (IBAction)didTapTwo:(id)sender {
    [self.wormhole passMessageObject:@{@"buttonNumber" : @(2)} identifier:@"button"];
}

- (void)clickButton:(id)sender {
    if (self.extensionContext) {
        [self.extensionContext openURL:[NSURL URLWithString:@"wormhole://test.com/jjjj/qqq?a=1&b=2&c=3?"] completionHandler:^(BOOL success) {
            NSLog(@"打开app %@",success ? @"成功" : @"失败");
        }];
    }
}


- (UIButton *)entryBtn {
    if (!_entryBtn) {
        _entryBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"widget" ofType:@"bundle"];
        NSBundle *widgetBundle = [NSBundle bundleWithPath:bundlePath];
        
        NSString *imgPath = [widgetBundle pathForResource:@"shortcut_pay" ofType:@"png"];

        [_entryBtn setImage:[UIImage imageWithContentsOfFile:imgPath] forState:UIControlStateNormal];
        [_entryBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _entryBtn;
}



@end

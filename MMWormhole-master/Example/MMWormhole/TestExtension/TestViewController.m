
//
//  TestViewController.m
//  TestExtension
//
//  Created by 周灿华 on 2019/11/13.
//  Copyright © 2019年 Conrad Stoll. All rights reserved.
//

#import "TestViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "TestItem.h"

#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0]
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define RandomColor             RGB(arc4random_uniform(255),arc4random_uniform(255),arc4random_uniform(255))


@interface TestViewController () <NCWidgetProviding>
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSArray *types;
@property (nonatomic, strong) UIImageView *moreView;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(0, 150); //这个设置是没用的,默认就是110的高度
    
    [self makeItems];
    
    [self.view addSubview:self.moreView];
    
    if (@available(iOS 10.0, *)) { //设置可折叠
        self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    //设置可以折叠和展开,系统有动画
//     self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    NSLog(@"viewWillLayoutSubviews");
    
    CGFloat screenW = self.view.frame.size.width;
    CGFloat screenH = self.view.frame.size.height;
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = 1.0 * screenW / self.items.count;
    CGFloat h = 110; //固定是110的高度
    for (TestItem *item in self.items) {
        item.frame = CGRectMake(x, y, w, h);
        x+= w;
    }
    
    self.moreView.frame = CGRectMake(0, h, screenW, screenH - h);
    
//    NSLog(@"self.view.frame :%@",NSStringFromCGRect(self.view.frame));
}


- (void)makeItems {
    
    NSArray *titles = @[
                        @"支付",
                        @"扫一扫",
                        @"付款",
                        @"服务",
                        ];
    
    NSArray *icons = @[
                        @"shortcut_pay",
                        @"shortcut_scan",
                        @"shortcut_qrcode",
                        @"shortcut_services",
                        ];

    for (NSInteger i = 0; i < 4; i++) {
        TestItem *item = [[TestItem alloc] initWithTitle:titles[i] icon:icons[i]];
        item.tag = i;
       
        [item addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:item];
        [self.items addObject:item];
    }
}

#pragma mark - NCWidgetProviding

///系统会定期自动调用该方法, 可以做一些数据更新
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    
    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


///widget 点击了折叠和展开按钮回调
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize  API_AVAILABLE(ios(10.0)){
    NSLog(@"maxSize : %@",NSStringFromCGSize(maxSize));
    
    if (@available(iOS 10.0, *)) {
        if (self.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeCompact) {
            self.preferredContentSize = CGSizeMake(0, 110);
        } else {
            self.preferredContentSize = CGSizeMake(0, 300);
        }
    }
}

#pragma mark - 其他

- (void)clickButton:(UIControl *)sender {
    NSString *urlStr = [self.types objectAtIndex:sender.tag];
    // 可以是一个网址, 比如 https://www.baidu.com
    [self.extensionContext openURL:[NSURL URLWithString:urlStr] completionHandler:^(BOOL success) {
        NSLog(@"打开主app %@",success ? @"成功" : @"失败");
    }];
}

#pragma mark - property

- (NSMutableArray *)items {
    if (!_items) {
        _items  = [[NSMutableArray alloc] init];
    }
    return _items;
}

- (NSArray *)types {
    if (!_types) {
        _types = @[
                   @"wormhole://pay",
                   @"wormhole://scan",
                   @"wormhole://qrcode",
                   @"wormhole://service"
                   ];
    }
    return _types;
}

#pragma mark - more

- (UIImageView *)moreView {
    if (!_moreView) {
        _moreView  = [[UIImageView alloc] init];
//        _moreView.contentMode = UIViewContentModeScaleAspectFit;
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"widget" ofType:@"bundle"];
        NSBundle *widgetBundle = [NSBundle bundleWithPath:bundlePath];
        
        NSString *imgPath = [widgetBundle pathForResource:@"lufei" ofType:@"png"];
        _moreView.image = [UIImage imageWithContentsOfFile:imgPath];
    }
    return _moreView;
}

@end


/*
 storyboard 使用 NSExtensionMainStoryboard,
 纯代码 使用 NSExtensionPrincipalClass
 
 <key>NSExtension</key>
 <dict>
 <key>NSExtensionMainStoryboard</key>
 <string>MainInterface</string>
 <key>NSExtensionPointIdentifier</key>
 <string>com.apple.widget-extension</string>
 <key>NSExtensionPrincipalClass</key>
 <string>TestViewController</string>
 </dict>
 */

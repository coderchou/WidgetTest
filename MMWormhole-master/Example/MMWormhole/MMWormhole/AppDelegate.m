//
//  AppDelegate.m
//  MMWormhole
//
//  Created by Conrad Stoll on 12/6/14.
//  Copyright (c) 2014 Conrad Stoll. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, strong) UIToolbar *too;
@property (nonatomic, assign) UIBackgroundTaskIdentifier taskID;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger count;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self creatShortcutItem];
    
    if(launchOptions){
        if([[[UIDevice currentDevice] systemVersion] doubleValue]>=9.0){
            UIApplicationShortcutItem *shortcutItem = [launchOptions valueForKey:UIApplicationLaunchOptionsShortcutItemKey];
            
            if (shortcutItem) {
                NSLog(@"----- %@ ------ = %s",shortcutItem.type,__FUNCTION__);
                //判断快捷选项标签唯一标识，根据不同标识执行不同操作
                [self dealWithShortcut:shortcutItem.type];
                return NO;
            }
        }
    }
    
    return YES;
}


#pragma mark - 创建 shortcutItem

- (void)creatShortcutItem {
    //创建系统风格的icon
    //    UIApplicationShortcutIcon *icon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeShare];
    
    // 自定义icon，大小为 70*70 px
    UIApplicationShortcutIcon *payIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"shortcut_pay.png"];
    UIApplicationShortcutItem *payItem = [[UIApplicationShortcutItem alloc]initWithType:@"com.codingchou.test.pay" localizedTitle:@"支付" localizedSubtitle:nil icon:payIcon userInfo:nil];
    
    UIApplicationShortcutIcon *scanIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"shortcut_scan.png"];
    UIApplicationShortcutItem *scanItem = [[UIApplicationShortcutItem alloc]initWithType:@"com.codingchou.test.scan" localizedTitle:@"扫一扫" localizedSubtitle:nil icon:scanIcon userInfo:nil];
    
    UIApplicationShortcutIcon *qrcodeIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"shortcut_qrcode.png"];
    UIApplicationShortcutItem *qrcodeItem = [[UIApplicationShortcutItem alloc]initWithType:@"com.codingchou.test.qrcode" localizedTitle:@"付款" localizedSubtitle:nil icon:qrcodeIcon userInfo:nil];
    
    UIApplicationShortcutIcon *redpackIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"shortcut_redpacket.png"];
    UIApplicationShortcutItem *redpackItem = [[UIApplicationShortcutItem alloc]initWithType:@"com.codingchou.test.redpacket" localizedTitle:@"红包" localizedSubtitle:nil icon:redpackIcon userInfo:nil];
    
    //添加到快捷选项数组
    [UIApplication sharedApplication].shortcutItems = @[payItem,scanItem,qrcodeItem,redpackItem];
}



- (void)dealWithShortcut:(NSString*)type {
    NSLog(@"dealWithShortcut = %@",type);
    
    if([type isEqualToString:@"com.codingchou.test.pay"]){
        NSLog(@"快捷方式 -- 支付");
        
    } else if([type isEqualToString:@"com.codingchou.test.scan"]){
        NSLog(@"快捷方式 -- 扫一扫");
        
    } else if([type isEqualToString:@"com.codingchou.test.qrcode"]){
        NSLog(@"快捷方式 -- 付款");
        
    } else if([type isEqualToString:@"com.codingchou.test.redpacket"]){
        NSLog(@"快捷方式 -- 红包");
        
    }
}


#pragma mark - 当app已启动, 点击shortcutItem回调
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"快捷方式 : %@",shortcutItem.type);
    
    [self dealWithShortcut:shortcutItem.type];
    
    completionHandler(YES);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
//    NSLog(@"applicationWillResignActive");
    
    [self.window addSubview:self.too];
    self.too.frame = self.window.bounds;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    NSLog(@"applicationDidEnterBackground");
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.timer = [NSTimer  timerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    self.count = 0;
    
    
    __weak typeof (self) weakSelf = self;
    self.taskID = [application beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"后台倒数结束, app被挂起");
        [application endBackgroundTask:weakSelf.taskID];
        weakSelf.taskID = UIBackgroundTaskInvalid;
        
    }];
}



- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
//    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    NSLog(@"%@",@"applicationDidBecomeActive");
    [self.too removeFromSuperview];
    
    if (self.taskID != UIBackgroundTaskInvalid) {
        NSLog(@"后台倒数提前结束");
        
        [application endBackgroundTask:self.taskID];
        self.taskID = UIBackgroundTaskInvalid;

    }
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}



- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

    NSLog(@"openURL: %@",url);
    NSLog(@"我要跳转到 %@ 模块",url.host);
    
    if (options) {
        NSString *sourceApp = [options valueForKey:UIApplicationOpenURLOptionsSourceApplicationKey];
        NSLog(@"sourceApp : %@",sourceApp);
        
        //
    }
    
    return YES;
    
}

#pragma mark - 其他

- (void)tick {
    self.count ++;
    NSLog(@"开始后台计数 : %ld",(long)self.count);
}



- (UIToolbar *)too {
    if (!_too) {
        _too = [[UIToolbar alloc] init];
//        _too.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _too.barStyle = UIBarStyleDefault;
    }
    return _too;
}


@end

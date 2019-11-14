//
//  TestItem.m
//  TestExtension
//
//  Created by 周灿华 on 2019/11/13.
//  Copyright © 2019年 Conrad Stoll. All rights reserved.
//

#import "TestItem.h"

@interface TestItem ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation TestItem

- (instancetype)initWithTitle:(NSString *)title
                         icon:(NSString *)icon {
    self = [super init];
    if (self) {
        
        [self addSubview:self.iconView];
        [self addSubview:self.titleLabel];
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"widget" ofType:@"bundle"];
        NSBundle *widgetBundle = [NSBundle bundleWithPath:bundlePath];
        
        NSString *imgPath = [widgetBundle pathForResource:icon ?:@"" ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:imgPath];

        
        self.titleLabel.text = title;
        self.iconView.image = image;
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    
    //图标大小是70的
    CGFloat iconW = 45;
    CGFloat iconH = 45;
    

    self.iconView.frame = CGRectMake(0, 20, iconW, iconH);
    CGPoint iconCenter = self.iconView.center;
    iconCenter.x = width * 0.5;
    self.iconView.center = iconCenter;

    
    self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.iconView.frame) + 10, width, 14);
    CGPoint titleCenter = self.titleLabel.center;
    titleCenter.x = iconCenter.x;
    
}

#pragma mark - property


- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView  = [[UIImageView alloc] init];
    }
    return _iconView;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel  = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor darkTextColor];
    }
    return _titleLabel;
}


@end

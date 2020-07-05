//
//  TestCollectionReusableView.m
//  ZBSimpleLayoutDemo
//
//  Created by Zombie on 2020/7/4.
//  Copyright © 2020 Zombie. All rights reserved.
//

#import "TestCollectionReusableView.h"

@implementation TestCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _titleLabel = [UILabel new];
        [self addSubview:_titleLabel];
        self.backgroundColor = [UIColor colorWithRed:arc4random()%256 / 255.0 green:arc4random()%256 / 255.0  blue:arc4random()%256 / 255.0  alpha:1];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake(15, 0, self.bounds.size.width, self.bounds.size.height);
}

@end

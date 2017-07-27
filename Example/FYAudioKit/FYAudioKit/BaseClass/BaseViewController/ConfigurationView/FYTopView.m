//
//  FYTopView.m
//  FYAudioKit_Example
//
//  Created by liangbai on 2017/7/26.
//  Copyright © 2017年 boilwater. All rights reserved.
//

#import "FYTopView.h"

@implementation FYTopView

- (instancetype)init {
    if (!(self = [super init])) {
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

@end

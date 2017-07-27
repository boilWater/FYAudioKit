//
//  FYRecordEditView.m
//  FYAudioKit_Example
//
//  Created by liangbai on 2017/7/26.
//  Copyright © 2017年 boilwater. All rights reserved.
//

#import "FYRecordEditView.h"

@implementation FYRecordEditView

- (instancetype)init {
    if (!(self = [super init])) {
        self.backgroundColor = [UIColor cyanColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor cyanColor];
    }
    return self;
}

@end

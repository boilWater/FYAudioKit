//
//  FYMemoModel.h
//  FYAudioKit_Example
//
//  Created by liangbai on 2017/7/27.
//  Copyright © 2017年 boilwater. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYMemoModel : NSObject<NSCoding>

@property (copy, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSURL *url;
@property (copy, nonatomic, readonly) NSString *date;
@property (copy, nonatomic, readonly) NSString *time;

+ (instancetype)memoWithTitle:(NSString *)title url:(NSURL *)url;

/**
 delete current memo model form list of memos
 
 @return if delete the memo successfully return YES, otherwise NO
 */
- (BOOL)deleteMemo;

@end

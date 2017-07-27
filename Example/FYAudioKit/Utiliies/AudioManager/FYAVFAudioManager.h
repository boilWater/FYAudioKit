//
//  FYAVFAudioManager.h
//  FYAudioKit_Example
//
//  Created by liangbai on 2017/7/27.
//  Copyright © 2017年 boilwater. All rights reserved.
//

@class FYMemoModel;

@protocol FYAVFAudioManagerDelegate <NSObject>

@end

typedef void(^FYAVFAudioManagerStopCompletionHandler) (BOOL result);
typedef void(^FYAVFAudioManagerSaveCompletionHandler) (BOOL result, FYMemoModel *memoModel);
typedef void(^FYAVFAudioManagerErrorHandler)(NSError *error);

#import <Foundation/Foundation.h>

@interface FYAVFAudioManager : NSObject

@property (strong, nonatomic) NSString *formattedCurrentTime;
@property (weak, nonatomic) id<FYAVFAudioManagerDelegate> delegate;

- (BOOL)record;

- (void)pause;

- (void)stopWithCompletionHandler:(FYAVFAudioManagerStopCompletionHandler)completion;

- (void)saveRecordingWithName:(NSString *)name completionHandler:(FYAVFAudioManagerSaveCompletionHandler)completion failureHandler:(FYAVFAudioManagerErrorHandler)failure;

- (BOOL)playBackMemo:(FYMemoModel *)memoModel;

- (BOOL)startPlayer:(FYMemoModel *)memoModel;

- (void)stopPlayer;

@end

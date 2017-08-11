//
//  FYAudioRecorder.h
//  FYAudioKit
//
//  Created by liangbai on 2017/8/5.
//

@class FYMemoModel;

#import <Foundation/Foundation.h>

@protocol FYAudioRecorderDelegate<NSObject>

@optional
- (void)beginInterruption;
- (void)endInterruption;
- (void)hasRestarted;
- (void)configurationHasChanged;
- (void)recorderWakeFormSleep;

@end

typedef void(^FYAudioRecorderStopCompletionHandler) (BOOL result);
typedef void(^FYAudioRecorderSaveCompletionHandler) (BOOL result, FYMemoModel *memoModel);
typedef void(^FYAudioRecorderErrorHandler) (NSError *error);

@interface FYAudioRecorder : NSObject

@property (weak, nonatomic) id<FYAudioRecorderDelegate> delegate;
@property (strong, nonatomic) NSString *formattedCurrentTime;

- (instancetype)initWithURL:(NSURL *)url error:(FYAudioRecorderErrorHandler)failure;

- (BOOL)start;

- (BOOL)pause;

- (void)stopWithCompletionHandler:(FYAudioRecorderStopCompletionHandler)completion;

- (void)saveWithAudioName:(NSString *)name completionHandler:(FYAudioRecorderSaveCompletionHandler)completion failureHandler:(FYAudioRecorderErrorHandler)failure;

@end

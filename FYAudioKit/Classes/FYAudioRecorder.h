//
//  FYAudioRecorder.h
//  FYAudioKit
//
//  Created by liangbai on 2017/8/5.
//

@class FYMemoModel;

#import <AVFoundation/AVFAudio.h>

@protocol FYAudioRecorderDelegate<NSObject>

- (void)recorderWasInterrupted;
- (void)recorderHasRestarted;
- (void)recorderConfigurationHasChanged;

@end

typedef void(^FYAudioRecorderStopCompletionHandler) (BOOL result);
typedef void(^FYAudioRecorderSaveCompletionHandler) (BOOL result, FYMemoModel *memoModel);
typedef void(^FYAudioRecorderErrorHandler) (NSError *error);

@interface FYAudioRecorder : AVAudioRecorder

@property (weak) id<FYAudioRecorderDelegate> delegate;
@property (strong, nonatomic) NSString *formattedCurrentTime;

- (instancetype)initWithURL:(NSURL *)url error:(FYAudioRecorderErrorHandler)failure;

- (BOOL)start;

- (BOOL)pause;

- (void)stopWithCompletionHandler:(FYAudioRecorderStopCompletionHandler)completion;

- (void)saveWithAudioName:(NSString *)name CompletionHandler:(FYAudioRecorderSaveCompletionHandler)completion failureHandler:(FYAudioRecorderErrorHandler)failure;

@end

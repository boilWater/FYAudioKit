//
//  FYAVFAudioManager.m
//  FYAudioKit_Example
//
//  Created by liangbai on 2017/7/27.
//  Copyright © 2017年 boilwater. All rights reserved.
//

#import "FYAVFAudioManager.h"
#import <AVFoundation/AVFAudio.h>
#import "FYMemoModel.h"

@interface FYAVFAudioManager ()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) FYAVFAudioManagerStopCompletionHandler completionHandler;

@end

@implementation FYAVFAudioManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuration];
    }
    return self;
}

#pragma mark - Configuration Paramters

- (void)configuration {
    NSString *tempDir = NSTemporaryDirectory();
    NSURL *fileUrl =[NSURL fileURLWithPath:[tempDir stringByAppendingPathComponent:@"fyaudiomemo.caf"]];
    NSDictionary *setting = @{AVFormatIDKey:@(kAudioFormatAppleIMA4),
                              AVSampleRateKey:@44100.0f,
                              AVNumberOfChannelsKey:@1,
                              AVEncoderBitDepthHintKey:@16,
                              AVEncoderAudioQualityKey:@(AVAudioQualityHigh)
                              };
    NSError *error = nil;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:fileUrl settings:setting error:&error];
    if (self.recorder) {
        self.recorder.delegate = self;
        self.recorder.meteringEnabled = YES;
        [self.recorder prepareToRecord];
    }
}

#pragma mark - Public Methods

- (BOOL)record {
    if (!self.recorder.isRecording) {
        return [self.recorder record];
    }
    return false;
}

- (void)pause {
    if (self.recorder.isRecording) {
        [self.recorder pause];
    }
}

- (void)stopWithCompletionHandler:(FYAVFAudioManagerStopCompletionHandler)completion {
    self.completionHandler = completion;
    [self.recorder stop];
}

- (void)saveRecordingWithName:(NSString *)name completionHandler:(FYAVFAudioManagerSaveCompletionHandler)completion failureHandler:(FYAVFAudioManagerErrorHandler)failure{
    NSTimeInterval currentTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSString *fileName = [NSString stringWithFormat:@"%@-%f.m4a", name, currentTimeInterval];
    
    NSString *docsDir = [self documentDictionary];
    NSString *docsPath = [docsDir stringByAppendingPathComponent:fileName];
    NSURL *audioSavedUrl = [NSURL fileURLWithPath:docsPath];
    NSURL *srcUrl = self.recorder.url;
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] copyItemAtURL:srcUrl toURL:audioSavedUrl error:&error];
    if (success) {
        completion(YES, [FYMemoModel memoWithTitle:name url:audioSavedUrl]);
        [self.recorder prepareToRecord];
    }else {
        failure(error);
    }
}

- (BOOL)playBackMemo:(FYMemoModel *)memoModel {
    NSError *error;
    if (!self.player) {
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:memoModel.url error:&error];
    }else if (self.player.isPlaying){
        [self.player stop];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:memoModel.url error:&error];
    }
    
    if (error) {
        NSLog(@"");
        return NO;
    }
    
    BOOL success = [self.player play];
    return success;
}

- (BOOL)startPlayer:(FYMemoModel *)memoModel {
    NSError *error;
    if (!self.player) {
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:memoModel.url error:&error];
    }
    BOOL success = false;
    if (!error) {
        success = [self.player play];
    }
    return success;
}

- (void)stopPlayer {
    if (self.player.isPlaying) {
        [self.player stop];
    }
}

- (NSString *)formattedCurrentTime {
    NSUInteger time = (NSUInteger)self.recorder.currentTime;
    NSInteger hours = time / 3600;
    NSInteger minutes = (time/60)%60;
    NSInteger seconds = time % 60;
    
    NSString *format = @"%02i:%02i:%2i";
    return [NSString stringWithFormat:format, hours, minutes, seconds];
}

#pragma mark - Document Dictionary

- (NSString *)documentDictionary {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}

#pragma mark - AVAudioRecordDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (self.completionHandler) {
        self.completionHandler(flag);
    }
}

@end

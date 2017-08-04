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

typedef NS_ENUM(NSInteger, FYAudioRecordSetupResult) {
    FYAudioRecordSetupResultSucess,
    FYAudioRecordSetupResultNotAuthorized,
    FYAudioRecordSetupResultConfigurationFiled
};

@interface FYAVFAudioManager ()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (nonatomic) FYAudioRecordSetupResult recordSetupResult;

@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) FYAVFAudioManagerStopCompletionHandler completionHandler;

@end

@implementation FYAVFAudioManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuration];
        [self addObserve];
    }
    return self;
}

#pragma mark - Configuration Paramters

- (void)configuration {
    self.recordSetupResult = FYAudioRecordSetupResultSucess;
    NSString *tempDir = NSTemporaryDirectory();
    NSURL *fileUrl =[NSURL fileURLWithPath:[tempDir stringByAppendingPathComponent:@"fyaudiomemo.caf"]];
    NSDictionary *setting = @{AVFormatIDKey:@(kAudioFormatAppleIMA4),
                              AVSampleRateKey:@44100.0f,
                              AVNumberOfChannelsKey:@1,
                              AVEncoderBitDepthHintKey:@16,
                              AVEncoderAudioQualityKey:@(AVAudioQualityHigh)
                              };
    __block NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session requestRecordPermission:^(BOOL granted) {
        if (granted) {
            
        }
        AVAudioSessionRecordPermission recordPermission = session.recordPermission;
        switch (recordPermission) {
            case AVAudioSessionRecordPermissionUndetermined:
            {
                self.recordSetupResult = FYAudioRecordSetupResultNotAuthorized;
                break;
            }
            case AVAudioSessionRecordPermissionDenied:
            {
                self.recordSetupResult = FYAudioRecordSetupResultNotAuthorized;
                break;
            }
            case AVAudioSessionRecordPermissionGranted:
            {
                self.recorder = [[AVAudioRecorder alloc] initWithURL:fileUrl settings:setting error:&error];
                break;
            }
        }
    }];
    if (self.recorder && error == nil) {
        self.recorder.delegate = self;
        self.recorder.meteringEnabled = YES;
        [self.recorder prepareToRecord];
    }else {
        self.recordSetupResult = FYAudioRecordSetupResultConfigurationFiled;
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

#pragma mark - Privated Method

#pragma mark -Document Dictionary

- (NSString *)documentDictionary {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
}

#pragma mark -AudioSession Preferences

- (void)configurationAudioSessionPreferences {
    NSError *audioPreferencesError = nil;
    BOOL result;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    result = [session setActive:NO error:&audioPreferencesError];
    if (!result) {
        NSLog(@"Error : session set inaction fail");
    }
    
    // I/o buffer duation 5 ms
    NSTimeInterval bufferDuration = 0.005;
    [session setPreferredIOBufferDuration:bufferDuration error:&audioPreferencesError];
    if (audioPreferencesError) {
        NSLog(@"Error : session set IOBufferDuration fail");
    }
    
    // sample rate 44.1k HZ
    double sampleRate = 44100.0;
    [session setPreferredSampleRate:sampleRate error:&audioPreferencesError];
    if (audioPreferencesError) {
        NSLog(@"Error : session set sample buffer fail");
    }
    
    result = [session setActive:YES error:&audioPreferencesError];
    if (!result) {
        NSLog(@"Error : session set restart action fail");
        NSLog(@"The current IOBufferDuration is %0.0f sample rate is %f", session.IOBufferDuration, session.sampleRate);
    }
}

- (void)changeMicrophoneForInputRouteWithOrientation:(NSString *)orientation {
    NSError *audioRouteError = nil;
    BOOL result = YES;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSArray<AVAudioSessionPortDescription *> *inputs = session.availableInputs;

    AVAudioSessionPortDescription *builtInMicPort = nil;
    for (AVAudioSessionPortDescription *port in inputs) {
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
            builtInMicPort = port;
            break;
        }
    }
    
    AVAudioSessionDataSourceDescription *frontDataSource = nil;
    for (AVAudioSessionDataSourceDescription *source in builtInMicPort.dataSources) {
        if ([source.orientation isEqualToString: AVAudioSessionOrientationFront]) {
            frontDataSource = source;
            break;
        }
    }
    
    if (frontDataSource) {
        result = [builtInMicPort setPreferredDataSource:frontDataSource error:&audioRouteError];
    }
    if (!result) {
        NSLog(@"Error : Audio session port set data source fail");
        NSLog(@"Detail error : %@", audioRouteError);
    }
    
    audioRouteError = nil;
    result = [session setPreferredInput:builtInMicPort error:&audioRouteError];
    if (!result) {
        NSLog(@"Error : Audio session set port fail");
        NSLog(@"Detail error : %@", audioRouteError);
    }
}

- (void)handleRouteChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    AVAudioSessionRouteChangeReason routeChangeReason = (AVAudioSessionRouteChangeReason)userInfo[AVAudioSessionRouteChangeReasonKey];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        {
            //handle new device available
            NSLog(@"");
            break;
        }
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            //handle old old removed
            NSLog(@"");
            break;
        }
        default:
            break;
    }
}

//handle secondary audio 
- (void)handleSecondaryAudio:(NSNotification *)notification {
    
}

#pragma mark - AVAudioRecordDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (self.completionHandler) {
        self.completionHandler(flag);
    }
}

#pragma  mark - Add Notifications

- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSecondaryAudio:) name:AVAudioSessionSilenceSecondaryAudioHintNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

@end

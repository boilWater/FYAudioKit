//
//  FYAudioRecorder.m
//  FYAudioKit
//
//  Created by liangbai on 2017/8/5.
//

#import "FYAudioRecorder.h"
#import "FYMemoModel.h"

typedef NS_ENUM(NSInteger, FYAudioRecorderSetupResult) {
    FYAudioRecorderSetupResultSucess,
    FYAudioRecorderSetupResultNotAuthorized,
    FYAudioRecorderSetupResultConfigurationFiled
};

typedef NS_ENUM(NSInteger, FYAudioMicrophoneMode) {
    FYAudioMicrophoneModeDefault,//default microphone built in iOS device
    FYAudioMicrophoneModePhone,
    FYAudioMicrophoneModeHead
};

typedef NS_ENUM(NSInteger, FYAudioHeadPhoneState) {
    FYAudioHeadPhoneStateDefault, //state of head phone disconnected
    FYAudioHeadPhoneStateConnected,
    FYAudioHeadPhoneStateDisConnected
};

@interface FYAudioRecorder ()<AVAudioRecorderDelegate>

//AudioSession
@property (strong, nonatomic) AVAudioSession *session;

//Recoder
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (assign, nonatomic) FYAudioRecorderSetupResult recorderSetupResult;
@property (strong, nonatomic) FYAudioRecorderStopCompletionHandler completionHandler;
@property (strong, nonatomic) NSURL *urlSavedAudio;

//Input route
@property (assign, nonatomic) FYAudioHeadPhoneState headPhoneState;

@end

@implementation FYAudioRecorder

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [self initWithURL:nil error:nil];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url
                      error:(FYAudioRecorderErrorHandler)failure{
    self = [super init];
    if (self) {
        self.urlSavedAudio = url;
        [self configurationWithError:^(NSError *error) {
            if (error) {
                failure(error);
                return ;
            }
            [self addNotifications];
        }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionSilenceSecondaryAudioHintNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

#pragma mark - Public Methods

- (BOOL)start {
    if (self.recorder) {
        if (self.recorder.isRecording) {
            [self.recorder pause];
            return [self.recorder prepareToRecord];
        }
        return [self.recorder record];
    }
    return NO;
}

- (BOOL)pause {
    if (self.recorder.isRecording) {
        [self.recorder pause];
        return [self.recorder prepareToRecord];
    }
    return NO;
}

- (void)stopWithCompletionHandler:(FYAudioRecorderStopCompletionHandler)completion {
    self.completionHandler = completion;
    [self.recorder stop];
}

- (void)saveWithAudioName:(NSString *)name
                CompletionHandler:(FYAudioRecorderSaveCompletionHandler)completion
                   failureHandler:(FYAudioRecorderErrorHandler)failure {
    NSError *error = nil;
    NSURL *srcURL = [self getAudioRecoderURL];
    NSURL *urlSaveAudioRecord = self.urlSavedAudio;
    if (!urlSaveAudioRecord) {
        urlSaveAudioRecord = [self getURLSavedAudioWithAudioName:name];
    }
    BOOL success = [[NSFileManager defaultManager] copyItemAtURL:srcURL toURL:urlSaveAudioRecord error:&error];
    if (success && error == nil) {
        completion(YES, [FYMemoModel memoWithTitle:name url:urlSaveAudioRecord]);
        [self.recorder prepareToRecord];
    }else {
        failure(error);
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

#pragma mark - Privated Methods

- (void)configurationWithError:(FYAudioRecorderErrorHandler)failure {
    self.recorderSetupResult = FYAudioRecorderSetupResultSucess;
    self.headPhoneState = FYAudioHeadPhoneStateDefault;
    
    _session = [AVAudioSession sharedInstance];
    __block AVAudioSessionRecordPermission recordPermission;
    [_session requestRecordPermission:^(BOOL granted) {
        recordPermission = _session.recordPermission;
        switch (recordPermission) {
            case AVAudioSessionRecordPermissionDenied:
            {
                self.recorderSetupResult = FYAudioRecorderSetupResultNotAuthorized;
                break;
            }
            case AVAudioSessionRecordPermissionGranted:
            {
                self.recorderSetupResult = FYAudioRecorderSetupResultSucess;
                break;
            }
                
            default:
            {
                self.recorderSetupResult = FYAudioRecorderSetupResultConfigurationFiled;
                break;
            }
        }
        
        if (!granted) {
            NSErrorDomain errorDomain = NSLocalizedString(@"Request record permission fail", nil);
            NSInteger code = 11201;
            NSDictionary *userInfo = @{@"cause": errorDomain,
                                       @"code":@(code),
                                       @"recordPeimission":@(recordPermission),
                                       @"granted":@(granted)
                                       };
            NSError *error = [NSError errorWithDomain:errorDomain code:code userInfo:userInfo];
            failure(error);
            return ;
        }
    }];
    NSError *error = nil;
    if (FYAudioRecorderSetupResultSucess == self.recorderSetupResult) {
        NSDictionary *settings = @{AVFormatIDKey:@(kAudioFormatAppleIMA4),
                                  AVSampleRateKey:@44100.0f,
                                  AVNumberOfChannelsKey:@1,
                                  AVEncoderBitDepthHintKey:@16,
                                  AVEncoderAudioQualityKey:@(AVAudioQualityHigh)
                                  };
        NSURL *urlAudioRecoder = [self getAudioRecoderURL];
        self.recorder = [[AVAudioRecorder alloc] initWithURL:urlAudioRecoder settings:settings error:&error];
        if (!error) {
            self.recorderSetupResult = FYAudioRecorderSetupResultConfigurationFiled;
            failure(error);
            return;
        }
        if (self.recorder && error == nil) {
            self.recorder.delegate = self;
            self.recorder.meteringEnabled = YES;
            [self.recorder prepareToRecord];
        }
    }
}

- (NSURL *)getAudioRecoderURL{
    NSString *tempDir = NSTemporaryDirectory();
    NSURL *fileUrl =[NSURL fileURLWithPath:[tempDir stringByAppendingPathComponent:@"fyaudiomemo.caf"]];
    return fileUrl;
}

- (NSURL *)getURLSavedAudioWithAudioName:(NSString *)audioName {
    NSTimeInterval currentTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSString *fileName = [NSString stringWithFormat:@"%@-%f.m4a", audioName, currentTimeInterval];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = paths[0];
    NSString *docsPath = [docsDir stringByAppendingPathComponent:fileName];
    NSURL *audioSavedUrl = [NSURL fileURLWithPath:docsPath];
    return audioSavedUrl;
}

#pragma mark - AVAudioSessionDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (self.completionHandler) {
        self.completionHandler(flag);
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    [recorder stop];
}

#pragma mark - Add Notification and Observer

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSecondaryAudio:) name:AVAudioSessionSilenceSecondaryAudioHintNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

- (void)handleRouteChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    AVAudioSessionRouteChangeReason routeChangeReason = (AVAudioSessionRouteChangeReason)userInfo[AVAudioSessionRouteChangeReasonKey];
    FYAudioMicrophoneMode microphoneMode = FYAudioMicrophoneModeDefault;
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        {
            //handle new device available
            NSArray<AVAudioSessionPortDescription *> *outputs = _session.currentRoute.outputs;
            for (AVAudioSessionPortDescription *output in outputs) {
                if ([output.portType isEqualToString: AVAudioSessionPortHeadphones]) {
                    _headPhoneState = FYAudioHeadPhoneStateConnected;
                    microphoneMode = FYAudioMicrophoneModeHead;
                }
            }
            NSLog(@"");
            break;
        }
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            //handle old old removed
            NSArray<AVAudioSessionPortDescription *> *outputs = _session.currentRoute.outputs;
            for (AVAudioSessionPortDescription *output in outputs) {
                if ([output.portType isEqualToString:AVAudioSessionPortHeadphones]) {
                    _headPhoneState = FYAudioHeadPhoneStateDisConnected;
                    microphoneMode = FYAudioMicrophoneModePhone;
                }
            }
            NSLog(@"");
            break;
        }
        default:
        {
            
            break;
        }
    }
    [self changeInputRouteWithMicrophoneMode:microphoneMode];
}

//handle secondary audio
- (void)handleSecondaryAudio:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    AVAudioSessionSilenceSecondaryAudioHintType secondaryAudioHintType = (AVAudioSessionSilenceSecondaryAudioHintType)userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey];
    switch (secondaryAudioHintType) {
        case AVAudioSessionSilenceSecondaryAudioHintTypeBegin:
        {
            
            break;
        }
        case AVAudioSessionSilenceSecondaryAudioHintTypeEnd:
        {
            
            break;
        }
    }
}

- (void)changeInputRouteWithMicrophoneMode:(FYAudioMicrophoneMode)microphoneMode {
    
    NSError *audioRouteError = nil;
    BOOL result = YES;
    
    NSArray<AVAudioSessionPortDescription *> *inputs = _session.availableInputs;
    
    AVAudioSessionPortDescription *builtInMicPort = nil;
    AVAudioSessionDataSourceDescription *frontDataSource = nil;
    switch (microphoneMode) {
        case FYAudioMicrophoneModePhone:
        {
            for (AVAudioSessionPortDescription *port in inputs) {
                if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
                    builtInMicPort = port;
                    break;
                }
            }
            for (AVAudioSessionDataSourceDescription *source in builtInMicPort.dataSources) {
                if ([source.orientation isEqualToString:AVAudioSessionOrientationBottom]) {
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
            break;
        }
        case FYAudioMicrophoneModeHead:
        {
            for (AVAudioSessionPortDescription *port in inputs) {
                if ([port.portType isEqual:AVAudioSessionPortHeadphones]) {
                    builtInMicPort = port;
                    break;
                }
            }
        }
        default:
        {
            
            break;
        }
    }
    
    audioRouteError = nil;
    result = [_session setPreferredInput:builtInMicPort error:&audioRouteError];
    if (!result) {
        NSLog(@"Error : Audio session set port fail");
        NSLog(@"Detail error : %@", audioRouteError);
    }
}

@end

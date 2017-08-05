//
//  FYAudioRecorder.m
//  FYAudioKit
//
//  Created by liangbai on 2017/8/5.
//

#import "FYAudioRecorder.h"

typedef NS_ENUM(NSInteger, FYAudioRecorderSetupResult) {
    FYAudioRecorderSetupResultSucess,
    FYAudioRecorderSetupResultNotAuthorized,
    FYAudioRecorderSetupResultConfigurationFiled
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
        NSString *tempDir = NSTemporaryDirectory();
        NSURL *fileUrl =[NSURL fileURLWithPath:[tempDir stringByAppendingPathComponent:@"fyaudiomemo.caf"]];
        self = [self initWithURL:fileUrl error:nil];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url
                      error:(FYAudioRecorderErrorHandler)failure{
    self = [super init];
    if (self) {
        self.urlSavedAudio = url;
        [self configurationWithError:^(NSError *error) {
            failure(error);
        }];
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL)start {
    return NO;
}

- (BOOL)pause {
    return NO;
}

- (void)stopWithCompletionHandler:(FYAudioRecorderStopCompletionHandler)completion {
    
}

- (void)saveWithCompletionHandler:(FYAudioRecorderSaveCompletionHandler)completion
                   failureHandler:(FYAudioRecorderErrorHandler)failure {
    
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
        self.recorder = [[AVAudioRecorder alloc] initWithURL:_urlSavedAudio settings:settings error:&error];
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

@end

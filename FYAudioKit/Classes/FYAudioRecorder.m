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

@interface FYAudioRecorder ()

//AudioSession
@property (strong, nonatomic) AVAudioSession *session;

//Recoder
@property (assign, nonatomic) FYAudioRecorderSetupResult recorderSetupResult;
@property (strong, nonatomic) FYAudioRecorderStopCompletionHandler completionHandler;
@property (strong, nonatomic) NSURL *urlSavedAudio;
@property (nonatomic) NSError *outError;

//Input route
@property (assign, nonatomic) FYAudioHeadPhoneState headPhoneState;

@end

@implementation FYAudioRecorder

//有问题
//- (instancetype)init {
//    self = [super init];
//    [self initWithURL:<#(NSURL *)#> error:<#(NSError *__autoreleasing *)#>]
//}

- (instancetype)initWithURL:(NSURL *)url
                      error:(NSError **)outError {
    self = [super init];
    if (self) {
        self.urlSavedAudio = url;
        
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

- (void)configuration {
    
}

- (void)configurationWithError:(NSError **)error {
    self.recorderSetupResult = FYAudioRecorderSetupResultSucess;
    self.headPhoneState = FYAudioHeadPhoneStateDefault;
    
    _session = [AVAudioSession sharedInstance];
    [_session requestRecordPermission:^(BOOL granted) {
        AVAudioSessionRecordPermission recordPermission = _session.recordPermission;
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
            
            return ;
        }
    }];
}


@end

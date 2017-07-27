//
//  FYAVFViewController.m
//  FYAudioKit_Example
//
//  Created by liangbai on 2017/7/25.
//  Copyright © 2017年 boilwater. All rights reserved.
//

typedef NS_ENUM(NSInteger, FYAudioRecordMode) {
    FYAudioRecordModeRecording = 0,
    FYAudioRecordModePaused = 1,
    FYAudioRecordModeNot
};

#import "FYAVFViewController.h"
#import "FYAVFAudioManager.h"
#import "FYMemoModel.h"

@interface FYAVFViewController ()

@property (strong, nonatomic) FYAVFAudioManager *audioManager;
@property (strong, nonatomic) FYMemoModel *memoModel;
@property (nonatomic) FYAudioRecordMode recordMode;

@end

@implementation FYAVFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initParamters];
    [self configurationClickedEvent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -

- (void)initParamters {
    self.recordMode = FYAudioRecordModeNot;
    _audioManager = [[FYAVFAudioManager alloc] init];
}

- (void)configurationClickedEvent {
    [self.recordButton addTarget:self action:@selector(clickRecordButton:) forControlEvents:UIControlEventTouchDown];
    [self.playButton addTarget:self action:@selector(clickPlayAudioButton:) forControlEvents:UIControlEventTouchDown];
    [self.saveButton addTarget:self action:@selector(clickSaveButton:) forControlEvents:UIControlEventTouchDown];
}

#pragma mark - Record audio

- (void)clickRecordButton:(UIButton *)sender {
    if (FYAudioRecordModeNot == self.recordMode) {
        self.recordMode = FYAudioRecordModeRecording;
    }else {
        self.recordMode = (self.recordMode == FYAudioRecordModeRecording) ? FYAudioRecordModePaused : FYAudioRecordModeRecording;
    }
    
    [sender setSelected:!self.recordMode];
    
    if (FYAudioRecordModeRecording == self.recordMode) {
        [_audioManager record];
    }else if(FYAudioRecordModePaused == self.recordMode) {
        [_audioManager pause];
    }
}

#pragma mark - Save audio

- (void)clickSaveButton:(UIButton *)sender {
    NSLog(@"save ...");
    [_audioManager saveRecordingWithName:@"name" completionHandler:^(BOOL result, FYMemoModel *memoModel) {
        _memoModel = memoModel;
    } failureHandler:^(NSError *error) {
        
    }];
}

#pragma mark - Play audio

- (void)clickPlayAudioButton:(UIButton *)sender {
    NSLog(@"play ...");
    [_audioManager playBackMemo:_memoModel];
}

@end

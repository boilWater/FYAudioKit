//
//  FYAVFViewController.m
//  FYAudioKit_Example
//
//  Created by liangbai on 2017/7/25.
//  Copyright © 2017年 boilwater. All rights reserved.
//

typedef NS_ENUM(NSInteger, FYAudioRecordMode) {
    FYAudioRecordModePaused = 0,
    FYAudioRecordModeRecording = 1,
    FYAudioRecordModeNot
};

#import "FYAVFViewController.h"

@interface FYAVFViewController ()

@property (nonatomic) FYAudioRecordMode audioRecordMode;

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
    self.audioRecordMode = FYAudioRecordModeNot;
}

- (void)configurationClickedEvent {
    [self.recordButton addTarget:self action:@selector(clickRecordButton:) forControlEvents:UIControlEventTouchDown];
    [self.playButton addTarget:self action:@selector(clickPlayAudioButton:) forControlEvents:UIControlEventTouchDown];
    [self.saveButton addTarget:self action:@selector(clickSaveButton:) forControlEvents:UIControlEventTouchDown];
}

#pragma mark - Record audio

- (void)clickRecordButton:(UIButton *)sender {
    if (FYAudioRecordModeNot == self.audioRecordMode) {
        self.audioRecordMode = FYAudioRecordModeRecording;
    }else {
        self.audioRecordMode = (self.audioRecordMode == FYAudioRecordModeRecording) ? FYAudioRecordModePaused : FYAudioRecordModeRecording;
    }
    
    [sender setSelected:self.audioRecordMode];
}

#pragma mark - Save audio

- (void)clickSaveButton:(UIButton *)sender {
    NSLog(@"save ...");
}

#pragma mark - Play audio

- (void)clickPlayAudioButton:(UIButton *)sender {
    NSLog(@"play ...");
}

@end

//
//  FYBaseViewController.m
//  FYAudioKit_Example
//
//  Created by liangbai on 2017/7/26.
//  Copyright © 2017年 boilwater. All rights reserved.
//

#import "FYBaseViewController.h"
#import "CommonConstant.h"
#import "FYTopView.h"
#import "FYSoundCurveView.h"
#import "FYViewController.h"
#import "FYMemoTableView.h"
#import "FYRecordEditView.h"

//这里的 layout 有个问题：采用比例进行布局，但是在取余是会取整误差较大

#define HEIGHT_TIMES_SHOW_AUDIO_VIEW 32/512
#define HEIGHT_TIMES_SOUND_CURVE_VIEW 229/512
#define HEIGHT_TIMES_RECORD_EDIT_VIEW 41/512
#define HEIGHT_TIMES_RECORD_VIEW 77/512
#define HEIGHT_TIMES_DETAIL_TABLE_VIEW 118/512

#define WIDTH_PLAY_BUTTON 35/288
#define WIDTH_RECORD_BUTTON 48/288
#define WIDTH_SAVED_BUTTON 48/288

@interface FYBaseViewController ()
//<UIGestureRecognizerDelegate>

@property (strong, nonatomic) FYTopView *showAudioView;
@property (strong, nonatomic) FYSoundCurveView *soundCurveView;
@property (strong, nonatomic) FYRecordEditView *recordEditView;
@property (strong, nonatomic) FYMemoTableView *memoListView;

@end

@implementation FYBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initHierarchy];
    [self initParamters];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - 

- (void)initHierarchy {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.showAudioView];
    [self.view addSubview:self.soundCurveView];
    [self.view addSubview:self.recordEditView];
    [self.view addSubview:self.memoListView];
    [self.view addSubview:self.recordButton];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.saveButton];
}

- (void)initParamters {
    UISwipeGestureRecognizer *swipeGestureLeftToRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(retureHomeView)];
    
    [self.view addGestureRecognizer:swipeGestureLeftToRight];
}

- (void)retureHomeView {
    FYViewController *homeViewController = [[FYViewController alloc] init];
    [self presentViewController:homeViewController animated:YES completion:nil];
}

#pragma mark - lazyLoading

- (FYTopView *)showAudioView {
    if (!_showAudioView) {
        NSUInteger position_Y = STATUS_HEIGHT;
        NSUInteger heightShowAudioView = SCREEN_HEIGHT * HEIGHT_TIMES_SHOW_AUDIO_VIEW ;
        _showAudioView = [[FYTopView alloc] initWithFrame:CGRectMake(0, position_Y, SCREEN_WIDTH, heightShowAudioView)];
    }
    return _showAudioView;
}

- (FYSoundCurveView *)soundCurveView {
    if (!_soundCurveView) {
        NSUInteger position_Y = BottomPositionView(_showAudioView);
        NSUInteger heightSoundCurveView = SCREEN_HEIGHT * HEIGHT_TIMES_SOUND_CURVE_VIEW;
        CGRect rectSoundCurveView = CGRectMake(0, position_Y, SCREEN_WIDTH, heightSoundCurveView);
        _soundCurveView = [[FYSoundCurveView alloc] initWithFrame:rectSoundCurveView];
    }
    return _soundCurveView;
}

- (FYRecordEditView *)recordEditView {
    if (!_recordEditView) {
        NSUInteger heightSoundCurveView = SCREEN_HEIGHT * HEIGHT_TIMES_RECORD_EDIT_VIEW;
        NSUInteger position_Y = BottomPositionView(_soundCurveView);
        CGRect rectMemoListView = CGRectMake(0, position_Y, SCREEN_WIDTH, heightSoundCurveView);
        _recordEditView = [[FYRecordEditView alloc] initWithFrame:rectMemoListView];
    }
    return _recordEditView;
}

- (FYMemoTableView *)memoListView {
    if (!_memoListView) {
         NSUInteger heightSoundCurveView = SCREEN_HEIGHT * HEIGHT_TIMES_RECORD_VIEW + STATUS_HEIGHT;
        NSUInteger position_Y = SCREEN_HEIGHT - heightSoundCurveView;
        CGRect rectMemoListView = CGRectMake(0, position_Y, SCREEN_WIDTH, heightSoundCurveView);
        _memoListView = [[FYMemoTableView alloc] initWithFrame:rectMemoListView];
    }
    return _memoListView;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        CGFloat widthView = SCREEN_HEIGHT - BottomPositionView(_recordEditView) - HEIGHTVIEW(_memoListView);
        CGFloat position_Center = BottomPositionView(_recordEditView) + widthView/2;
        CGFloat widthRecordButton = SCREEN_WIDTH * WIDTH_RECORD_BUTTON;
        _recordButton = [[UIButton alloc] init];
        [_recordButton setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        [_recordButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        [_recordButton setBackgroundImage:[UIImage imageNamed:@"transport_bg"] forState:UIControlStateNormal];
        _recordButton.frame = CGRectMake(0, 0, widthRecordButton, widthRecordButton);
        _recordButton.center = CGPointMake(SCREEN_WIDTH/2, position_Center);
    }
    return _recordButton;
}

- (UIButton *)playButton {
    if (!_playButton) {
        CGFloat widthView = SCREEN_HEIGHT - BottomPositionView(_recordEditView) - HEIGHTVIEW(_memoListView);
        CGFloat position_CenterY = BottomPositionView(_recordEditView) + widthView/2;
        CGFloat position_CenterX = LeftPositionView(_recordButton) - 20 - WIDTHVIEW(_recordButton)/2;
        CGFloat widthRecordButton = SCREEN_WIDTH * WIDTH_PLAY_BUTTON;
        _playButton = [[UIButton alloc] init];
        
        _playButton.titleLabel.textColor = [UIColor whiteColor];
        _playButton.titleLabel.text = @"播放";
        [_playButton setBackgroundImage:[UIImage imageNamed:@"stop"] forState:UIControlStateSelected];
        
        [_playButton setBackgroundImage:[UIImage imageNamed:@"transport_bg"] forState:UIControlStateNormal];
        _playButton.frame = CGRectMake(0, 0, widthRecordButton, widthRecordButton);
        _playButton.center = CGPointMake(position_CenterX, position_CenterY);
        
    }
    return _playButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        CGFloat widthView = SCREEN_HEIGHT - BottomPositionView(_recordEditView) - HEIGHTVIEW(_memoListView);
        CGFloat position_CenterY = BottomPositionView(_recordEditView) + widthView/2;
        CGFloat position_CenterX = RightPositionView(_recordButton) + 20 + WIDTHVIEW(_recordButton)/2;
        CGFloat widthRecordButton = SCREEN_WIDTH * WIDTH_PLAY_BUTTON;
        _saveButton = [[UIButton alloc] init];
        
        _saveButton.titleLabel.textColor = [UIColor whiteColor];
        _saveButton.titleLabel.text = @"保存";
        [_saveButton setBackgroundImage:[UIImage imageNamed:@"stop"] forState:UIControlStateSelected];
        
        [_saveButton setBackgroundImage:[UIImage imageNamed:@"transport_bg"] forState:UIControlStateNormal];
        _saveButton.frame = CGRectMake(0, 0, widthRecordButton, widthRecordButton);
        _saveButton.center = CGPointMake(position_CenterX, position_CenterY);
    }
    return _saveButton;
}

@end

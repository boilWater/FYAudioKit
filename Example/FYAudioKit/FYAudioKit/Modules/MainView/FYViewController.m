//
//  FYViewController.m
//  FYCameraKit
//
//  Created by boilwater on 06/23/2017.
//  Copyright (c) 2017 boilwater. All rights reserved.
//

@interface FYRecordStyleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *memoName;
@property (weak, nonatomic) IBOutlet UILabel *memoDate;
@property (weak, nonatomic) IBOutlet UILabel *memoDuration;

@end

@implementation FYRecordStyleCell

@end

#import "FYViewController.h"
#import "CommonConstant.h"
#import "FYATBViewController.h"
#import "FYAVFViewController.h"

@interface FYViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITextView *titleView;
@property (strong, nonatomic) UITableView *recordTableView;
@property (strong, nonatomic) NSMutableArray *recordStyleArray;

@end

static NSString * FYRECORDSTYLECELL = @"FYRecordStyleCell";

@implementation FYViewController

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initHierarchy];
    [self initParamters];
}

- (void)didReceiveMemoryWarning {
    
}

#pragma mark - init configurations

- (void)initHierarchy {
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.recordTableView];
}

- (void)initParamters {
    _recordStyleArray = @[@"使用 AVFoundation 实现音频处理", @"使用 AudioToolBox 试下音频处理"].mutableCopy;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _recordStyleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FYRecordStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:FYRECORDSTYLECELL];
    
    if (!cell) {
        cell = [[FYRecordStyleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FYRECORDSTYLECELL];
    }
    cell.textLabel.text = _recordStyleArray[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController;
    
    switch (indexPath.row) {
        case 0:
        {
            viewController = [[FYAVFViewController alloc] init];
            break;
        }
        case 1:
        {
            viewController = [[FYATBViewController alloc] init];
            break;
        }
    }
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - lazyLoading

- (UITextView *)titleView {
    if (!_titleView) {
        CGFloat position_Y  = STATUS_HEIGHT;
        CGFloat heightTitleView = 30.0f;
        _titleView = [[UITextView alloc] initWithFrame:CGRectMake(0, position_Y, SCREEN_WIDTH, heightTitleView)];
        _titleView.text = @"FYAudioKit";
        _titleView.backgroundColor = [UIColor grayColor];
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.font = [UIFont systemFontOfSize:16.0f];
    }
    return _titleView;
}

- (UITableView *)recordTableView {
    if (!_recordTableView) {
        CGFloat position_Y = BottomPositionView(_titleView);
        _recordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, position_Y, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        _recordTableView.delegate = self;
        _recordTableView.dataSource = self;
    }
    return _recordTableView;
}

@end
    

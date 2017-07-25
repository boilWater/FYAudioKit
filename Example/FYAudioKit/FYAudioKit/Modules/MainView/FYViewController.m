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
#import "FYATBViewController.h"
#import "FYAVFViewController.h"

@interface FYViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *recordStyleTableView;

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
    
//    cell.memoName.text = _recordStyleArray[indexPath.row];
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

@end
    

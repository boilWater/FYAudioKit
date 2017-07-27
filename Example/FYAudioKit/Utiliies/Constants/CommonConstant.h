//
//  CommonConstant.h
//  FYAudioKit
//
//  Created by liangbai on 2017/7/26.
//  Copyright © 2017年 boilwater. All rights reserved.
//

#ifndef CommonConstant_h
#define CommonConstant_h


#endif /* CommonConstant_h */

#pragma mark - Common



#pragma mark - User interface

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define STATUS_WIDTH ([UIApplication sharedApplication].statusBarFrame.size.width)
#define STATUS_HEIGHT ([UIApplication sharedApplication].statusBarFrame.size.height)
//_titleView.frame.origin.y + _titleView.bounds.size.height;

#define HEIGHTVIEW(view) (view.bounds.size.height)
#define WIDTHVIEW(view) (view.bounds.size.width)

#define TopPositionView(view) (view.frame.origin.y)
#define BottomPositionView(view) ((view.frame.origin.y)+(view.bounds.size.height))
#define LeftPositionView(view) (view.frame.origin.x)
#define RightPositionView(view) ((view.frame.origin.x)+(view.bounds.size.width))

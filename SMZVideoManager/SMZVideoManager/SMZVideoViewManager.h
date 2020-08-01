//
//  SMZVideoViewManager.h
//  SMZVideoManager
//
//  Created by 孙明喆 on 2020/8/1.
//  Copyright © 2020 孙明喆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SMZVideoViewManager : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setupPlayerWith:(NSURL *)videoURL;

- (void)play;

- (void)pause;

- (void)replay;

- (void)destory;


@end


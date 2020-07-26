//
//  ViewController.m
//  SMZVideoManager
//
//  Created by 孙明喆 on 2020/7/26.
//  Copyright © 2020 孙明喆. All rights reserved.
//

#import "ViewController.h"
#import "SMZVideoManager.h"

#define creenWidth [UIApplication sharedApplication].windows[0].bounds.size.width
#define creenHeight [UIApplication sharedApplication].windows[0].bounds.size.height

@interface ViewController ()

@end

static NSString *videoUrl = @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *videoView = [[UIView alloc] initWithFrame:self.view.frame];
    videoView = [[SMZVideoManager sharedInstance] createPlayViewFrame:CGRectMake(0, 0, creenWidth, creenHeight) withStringURL:videoUrl isLocalFile:NO];
    [self.view addSubview:videoView];
    // 也可以将视频播放完毕的监听加在这里，需要将manager中的移除掉
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playBackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:[[SMZVideoManager sharedInstance] getCurrentPlayerItem]];
    
    [[SMZVideoManager sharedInstance] startVideo];
}
 
- (void) playBackFinished:(NSNotification *)notification{
    [[SMZVideoManager sharedInstance] playBackFinished:notification withBlock:^{
        // 想做的操作
    }];
    
}


@end

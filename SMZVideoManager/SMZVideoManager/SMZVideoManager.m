//
//  SMZVideoManager.m
//  SMZVideoManager
//
//  Created by 孙明喆 on 2020/7/26.
//  Copyright © 2020 孙明喆. All rights reserved.
//

#import "SMZVideoManager.h"

@interface SMZVideoManager ()

@property (nonatomic, assign) CGFloat videoH;
@property (nonatomic, assign) CGFloat videoW;

@end

@implementation SMZVideoManager

+ (SMZVideoManager *_Nullable) sharedInstance{
    static SMZVideoManager *__singleton__;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        __singleton__ = [[super allocWithZone:NULL] init];
    });
    return __singleton__;
}

- (UIView *)createPlayViewFrame:(CGRect)frame withStringURL:(NSString *)stringURL isLocalFile:(BOOL)isTrue{
    if (isTrue == YES){
        self.videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:stringURL] options:nil];
    } else  {
        self.videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:stringURL] options:nil];
    }
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.videoAsset];
    // 添加观察者
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    // 获取当前视频的尺寸
    [self getVideoSize:self.videoAsset];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    // 监听是否 播放完毕
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playBackFinished:withBlock:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    
    self.playLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playLayer.frame = frame;
    // 填充模式
    self.playLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    UIView *videoView = [[UIView alloc] initWithFrame:frame];
    [videoView.layer addSublayer:self.playLayer];
    
    return videoView;
}

#pragma mark - 获取视频的某些属性
// 获取视频尺寸
- (void)getVideoSize:(AVAsset *)videoAsset{
    NSArray *array = videoAsset.tracks;
    CGSize videoSize = CGSizeZero;
    for (AVAssetTrack *track in array){
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]){
            videoSize  = track.naturalSize;
        }
    }
    self.videoH = videoSize.height;
    self.videoW = videoSize.width;
}

// 计算视频的比例，高 比 宽
- (CGFloat)getVideoScale{
    return self.videoH / self.videoW;
}

// 获取现在播放的ietm
- (AVPlayerItem *)getCurrentPlayerItem{
    return self.player.currentItem;
}

#pragma mark - 播放相关
- (void) startVideo{
    [self.player play];
}

- (void) pauseVideo{
    [self.player pause];
}

#pragma mark - 观察者相关
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]){
        AVPlayerItem *playItem = (AVPlayerItem *)object;
        if (playItem.status ==  AVPlayerStatusReadyToPlay){
            // 可以播放
        } else if (playItem.status == AVPlayerStatusFailed){
            // 失败
        } else {
            // 未知错误AVPlayerStatusUnknown
        }
    }
}

- (void)playBackFinished:(NSNotification *)notification withBlock:(void (^)(void))code{
    // 播放完毕的操作，这里 提供重新播放的能力
    self.playerItem = [notification object];
    [self.playerItem seekToTime:kCMTimeZero completionHandler:nil];
    code();
}

@end

//
//  SMZVideoViewManager.m
//  SMZVideoManager
//
//  Created by 孙明喆 on 2020/8/1.
//  Copyright © 2020 孙明喆. All rights reserved.
//

#import "SMZVideoViewManager.h"

@interface SMZVideoViewManager ()

// 视频相关组件
@property (nonatomic, strong) AVPlayer *player; // 播放器对象
@property (nonatomic, strong) AVPlayerItem *currentItem; // 播放属性
// 播放器观察者
@property (nonatomic, strong) id timeObser;

@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, assign) CGFloat videoScale;

@end

#define kScreenWidth [UIApplication sharedApplication].windows[0].bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].windows[0].bounds.size.height

@implementation SMZVideoViewManager

-  (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

// 准备播放器
- (void)setupPlayerWith:(NSURL *)videoURL{
    AVURLAsset *sset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    self.videoScale = [self getVideoSize:sset];
    [self creatPlayer:videoURL];
}


// 获取播放item
- (AVPlayerItem *)getPlayerItem:(NSURL *)videoURL {
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoURL];
    
    return item;
}


//  创建播放器
- (void)creatPlayer:(NSURL *)videoURL {
    if (!_player) {
        
        self.currentItem = [self getPlayerItem:videoURL];
        
        _player = [AVPlayer playerWithPlayerItem:self.currentItem];
        
        [self creatPlayerLayer];
        
        [self addPlayerObserver];
        
        [self addObserverWithPlayItem:self.currentItem];
        
        [self addNotificatonForPlayer];
    }
}

// 创建视图
- (void)creatPlayerLayer {
    CGFloat origin_x = 15;
    CGFloat main_width = kScreenWidth - (origin_x * 2);

    self.videoView = [[UIView alloc] initWithFrame:CGRectMake(origin_x, 85, main_width, main_width * self.videoScale)];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];

    layer.frame = CGRectMake(0, 0, self.videoView.frame.size.width, self.videoView.frame.size.height);
    
    layer.videoGravity = AVLayerVideoGravityResizeAspect;

    [self.videoView.layer addSublayer:layer];

    [self addSubview:self.videoView];
    
}

// 获取视频的比例
- (CGFloat)getVideoSize:(AVAsset *)videoAsset{
    NSArray *array = videoAsset.tracks;
    CGSize videoSize = CGSizeZero;
    for(AVAssetTrack  *track in array)
    {
        if([track.mediaType isEqualToString:AVMediaTypeVideo])
        {
              videoSize = track.naturalSize;
        }
    }
    CGFloat videoH = videoSize.height;
    CGFloat videoW = videoSize.width;
    return videoH / videoW;
}

#pragma mark - 播放器功能
// 播放
- (void)play {
    if (self.player.rate == 0) {
        [self addNotificatonForPlayer];
        [self addPlayerObserver];
    }
    [self.player play];
}

// 暂停 
- (void)pause {
    if (self.player.rate == 1.0) {
        [self.player pause];
        [self.player seekToTime:kCMTimeZero];
    }
}

// 重新开始
- (void)replay {
    if (self.player.rate == 1.0) {
        [self.player pause];
        [self.player seekToTime:kCMTimeZero];
        [self removeNotification];
    } else if (self.player.rate == 0){
        [self addNotificatonForPlayer];
        [self play];
    }
}

- (void)destory {
    [self pause];
    [self removeNotification];
    [self removePlayerObserver];
}

#pragma mark - 添加 监控
// 给player 添加 time observer
- (void)addPlayerObserver {
    __weak typeof(self)weakSelf = self;
    _timeObser = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        AVPlayerItem *playerItem = weakSelf.player.currentItem;
        
        float current = CMTimeGetSeconds(time);
        
        float total = CMTimeGetSeconds([playerItem duration]);

        NSLog(@"当前播放进度 %.2f/%.2f.",current,total);
        
    }];
}
// 移除 time observer
- (void)removePlayerObserver {
    [_player removeTimeObserver:_timeObser];
}

- (void)addObserverWithPlayItem:(AVPlayerItem *)item {
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}
//  移除 item 的 observer
- (void)removeObserverWithPlayItem:(AVPlayerItem *)item {
    [item removeObserver:self forKeyPath:@"status"];
    [item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    AVPlayerItem *item = object;
    if ([keyPath isEqualToString:@"status"]) {// 播放状态
        
        [self handleStatusWithPlayerItem:item];
        
    }
}

- (void)handleStatusWithPlayerItem:(AVPlayerItem *)item {
    AVPlayerItemStatus status = item.status;
    switch (status) {
        case AVPlayerItemStatusReadyToPlay:   // 准备好播放
            NSLog(@"AVPlayerItemStatusReadyToPlay");
            
            break;
        case AVPlayerItemStatusFailed:        // 播放出错
            
            NSLog(@"AVPlayerItemStatusFailed");
            
            break;
        case AVPlayerItemStatusUnknown:       // 状态未知
            
            NSLog(@"AVPlayerItemStatusUnknown");
            
            break;
            
        default:
            break;
    }
    
}

- (void)addNotificatonForPlayer {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(videoPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [center addObserver:self selector:@selector(videoPlayError:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [center addObserver:self selector:@selector(videoPlayEnterBack:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(videoPlayBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
// 移除 通知
- (void)removeNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//    [center removeObserver:self name:AVPlayerItemTimeJumpedNotification object:nil];
    [center removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [center removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [center removeObserver:self];
}

// 视频播放结束
- (void)videoPlayEnd:(NSNotification *)notification {
    NSLog(@"视频播放结束");
//    self.currentItem = [notic object];
//    [self.currentItem seekToTime:kCMTimeZero completionHandler:nil];
//    [self.player play];
    [self.player seekToTime:kCMTimeZero];
//    [self.player play];
}

// 视频异常中断
- (void)videoPlayError:(NSNotification *)notification {
    NSLog(@"视频异常中断");
}
// 进入后台
- (void)videoPlayEnterBack:(NSNotification *)notification {
    NSLog(@"进入后台");
}
// 返回前台
- (void)videoPlayBecomeActive:(NSNotification *)notification {
    NSLog(@"返回前台");
}

#pragma mark - 销毁 release
- (void)dealloc {
    NSLog(@"--- %@ --- 销毁了",[self class]);
    
    [self removeNotification];
    [self removePlayerObserver];
    [self removeObserverWithPlayItem:self.player.currentItem];
    
}

@end

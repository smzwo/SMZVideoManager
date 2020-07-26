//
//  SMZVideoManager.h
//  SMZVideoManager
//
//  Created by 孙明喆 on 2020/7/26.
//  Copyright © 2020 孙明喆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMZVideoManager : NSObject

// 视频相关组件
@property (nonatomic, strong) AVAsset *videoAsset;
@property (nonatomic, strong) AVPlayer *player; // 播放器对象
@property (nonatomic, strong) AVPlayerItem *playerItem; // 播放属性
@property (nonatomic, strong) AVPlayerLayer *playLayer; // 用于播放的layer

+ (SMZVideoManager *_Nullable) sharedInstance;

//- (AVPlayerLayer *)createPlayManagerWithStringURL:(NSString *)stringURL isLocalFile:(BOOL)isTrue;

- (UIView *)createPlayViewFrame:(CGRect)frame withStringURL:(NSString *)stringURL isLocalFile:(BOOL)isTrue;

- (CGFloat)getVideoScale;

//- (void)restartVideo;

- (void)startVideo;

- (void)pauseVideo;

- (void)playBackFinished:(NSNotification *)notification withBlock:(void(^)(void))code;

- (AVPlayerItem *)getCurrentPlayerItem;

//- (void) initManager;

//- (void)restartVideoWithItemIndex:(NSInteger)index;
//
//- (void)removeItemFromPlayer;
//
//- (void) resetPlayerItem;

@end

NS_ASSUME_NONNULL_END

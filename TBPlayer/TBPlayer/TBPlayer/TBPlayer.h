//
//  TBPlayer.h
//  TBPlayer
//
//  Created by qianjianeng on 16/1/31.
//  Copyright © 2016年 SF. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kTBPlayerStateChangedNotification;
FOUNDATION_EXPORT NSString *const kTBPlayerProgressChangedNotification;
FOUNDATION_EXPORT NSString *const kTBPlayerLoadProgressChangedNotification;

typedef NS_ENUM(NSInteger, TBPlayerState) {
    TBPlayerStateBuffering = 1,
    TBPlayerStatePlaying   = 2,
    TBPlayerStateStopped   = 3,
    TBPlayerStatePause     = 4
};

@interface TBPlayer : NSObject

@property (nonatomic, readonly) TBPlayerState state;
@property (nonatomic, readonly) CGFloat       loadedProgress;   //缓冲进度
@property (nonatomic, readonly) CGFloat       duration;         //视频总时间
@property (nonatomic, readonly) CGFloat       current;          //当前播放时间
@property (nonatomic, readonly) CGFloat       progress;         //0~1
@property (nonatomic          ) BOOL          stopWhenAppDidEnterBackground;// default is YES
@property (nonatomic          ) BOOL          cycleToPlay;     // default is NO

+ (instancetype)sharedInstance;
- (void)playWithUrl:(NSURL *)url showView:(UIView *)showView;
- (void)seekToTime:(CGFloat)seconds;

- (void)resume;
- (void)pause;
- (void)stop;

@end

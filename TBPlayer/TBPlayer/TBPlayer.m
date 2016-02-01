//
//  TBPlayer.m
//  TBPlayer
//
//  Created by qianjianeng on 16/1/31.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "TBPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define IOS_VERSION  ([[[UIDevice currentDevice] systemVersion] floatValue])
NSString *const kTBPlayerStateChangedNotification    = @"TBPlayerStateChangedNotification";
NSString *const kTBPlayerProgressChangedNotification = @"TBPlayerProgressChangedNotification";
NSString *const kTBPlayerLoadProgressChangedNotification = @"TBPlayerLoadProgressChangedNotification";


@interface TBPlayer ()

@property (nonatomic        ) TBPlayerState  state;
@property (nonatomic        ) CGFloat        loadedProgress;//缓冲进度
@property (nonatomic        ) CGFloat        duration;//视频总时间
@property (nonatomic        ) CGFloat        current;//当前播放时间

@property (nonatomic, strong) AVPlayer       *player;
@property (nonatomic, strong) AVPlayerItem   *currentPlayerItem;
@property (nonatomic, strong) AVPlayerLayer  *currentPlayerLayer;
@property (nonatomic, strong) NSObject       *playbackTimeObserver;
@property (nonatomic        ) BOOL           isPauseByUser; //是否被用户暂停
@property (nonatomic,       ) BOOL           isLocalVideo; //是否播放本地文件
@property (nonatomic,       ) BOOL           isFinishLoad; //是否下载完毕

@property (nonatomic, strong) UIView         *navBar;
@property (nonatomic, strong) UILabel        *currentTimeLabel;
@property (nonatomic, strong) UILabel        *totolTimeLabel;
@property (nonatomic, strong) UIProgressView *videoProgressView;  //缓冲进度条
@property (nonatomic, strong) UISlider       *playSlider;  //滑竿
@property (nonatomic, strong) UIButton       *stopButton;//播放暂停按钮

@end

@implementation TBPlayer

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id _sInstance;
    dispatch_once(&onceToken, ^{
        _sInstance = [[self alloc] init];
    });
    
    return _sInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isPauseByUser = YES;
        _loadedProgress = 0;
        _duration = 0;
        _current  = 0;
        _state = TBPlayerStateStopped;
        _stopWhenAppDidEnterBackground = YES;
    }
    return self;
}

- (void)configSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    // app在后台只有设置AVAudioSessionCategoryPlayAndRecord才能实现播放声音
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:NULL];
    }
    // 设置为AVAudioSessionModeVoiceChat保证了在后台可以播放音乐
    [audioSession setMode:AVAudioSessionModeVoiceChat error:NULL];
    // 设置这个仅保证插入耳机后切换到了耳机，如果是在耳机插入状态下播放音乐还是通过扬声器
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];
    [audioSession setActive:YES error:NULL];
}
//清空播放器监听属性
- (void)releasePlayer
{
    if (!self.currentPlayerItem) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"status"];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player removeTimeObserver:self.playbackTimeObserver];
    self.playbackTimeObserver = nil;
    self.currentPlayerItem = nil;
}

- (void)playWithUrl:(NSURL *)url showView:(UIView *)showView
{
    [self.player pause];
    [self releasePlayer];
    [self configSession];
    self.isPauseByUser = NO;
    self.loadedProgress = 0;
    self.duration = 0;
    self.current  = 0;
    
    self.currentPlayerItem = [AVPlayerItem playerItemWithURL:url];
    [self.currentPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentPlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlaybackStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.currentPlayerItem];

    
    // 本地文件不设置TBPlayerStateBuffering状态
    if ([url.scheme isEqualToString:@"file"]) {
        
        // 如果已经在TBPlayerStatePlaying，则直接发通知，否则设置状态
        if (self.state == TBPlayerStatePlaying) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTBPlayerStateChangedNotification object:nil];
        } else {
            self.state = TBPlayerStatePlaying;
        }
        
    } else {
        
        // 如果已经在TBPlayerStateBuffering，则直接发通知，否则设置状态
        if (self.state == TBPlayerStateBuffering) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTBPlayerStateChangedNotification object:nil];
        } else {
            self.state = TBPlayerStateBuffering;
        }
        
    }
    
    
    
    if (!self.player) {
        self.player = [AVPlayer playerWithPlayerItem:self.currentPlayerItem];
    } else {
        [self.player replaceCurrentItemWithPlayerItem:self.currentPlayerItem];
    }
    self.currentPlayerLayer       = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.currentPlayerLayer.frame = showView.bounds;
    [showView.layer addSublayer:self.currentPlayerLayer];
    if (!_navBar) {
        _navBar = [[UIView alloc] init];
        [showView addSubview:_navBar];
    }
    [self buildVideoNavBar];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBPlayerProgressChangedNotification object:nil];
}


- (void)seekToTime:(CGFloat)seconds
{
    if (self.state == TBPlayerStateStopped) {
        return;
    }
    
    seconds = MAX(0, seconds);
    seconds = MIN(seconds, self.duration);
    
    [self.player pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        self.isPauseByUser = NO;
        [self.player play];
        if (!self.currentPlayerItem.isPlaybackLikelyToKeepUp) {
            self.state = TBPlayerStateBuffering;
        }
        
    }];
}

- (void)resumeOrPause
{
    if (!self.currentPlayerItem) {
        return;
    }
    if (self.state == TBPlayerStatePlaying) {
        [_stopButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_play_hl"] forState:UIControlStateHighlighted];
        [self.player pause];
        self.state = TBPlayerStatePause;
    } else if (self.state == TBPlayerStatePause) {
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
        [self.player play];
        self.state = TBPlayerStatePlaying;
    }
    self.isPauseByUser = YES;
}

- (void)resume
{
    if (!self.currentPlayerItem) {
        return;
    }
    
    [self configSession];
    [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
    [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
    self.isPauseByUser = NO;
    [self.player play];
}

- (void)pause
{
    if (!self.currentPlayerItem) {
        return;
    }
    [_stopButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
    [_stopButton setImage:[UIImage imageNamed:@"icon_play_hl"] forState:UIControlStateHighlighted];
    self.isPauseByUser = YES;
    self.state = TBPlayerStatePause;
    [self.player pause];
}

- (void)stop
{
    self.isPauseByUser = YES;
    self.loadedProgress = 0;
    self.duration = 0;
    self.current  = 0;
    self.state = TBPlayerStateStopped;
    [self.player pause];
    [self releasePlayer];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBPlayerProgressChangedNotification object:nil];
}


- (CGFloat)progress
{
    if (self.duration > 0) {
        return self.current / self.duration;
    }
    
    return 0;
}


#pragma mark - observer

- (void)appDidEnterBackground
{
    if (self.stopWhenAppDidEnterBackground) {
        [self pause];
        [_stopButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_play_hl"] forState:UIControlStateHighlighted];
        self.state = TBPlayerStatePause;
    }
}
- (void)appDidEnterPlayGround
{
    if (!self.isPauseByUser && self.state == TBPlayerStatePause) {
        [self resume];
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
        self.state = TBPlayerStatePlaying;
    }
}

- (void)playerItemDidPlayToEnd:(NSNotification *)notification
{
    [self stop];
}

- (void)playerItemPlaybackStalled:(NSNotification *)notification
{
    // 这里网络不好的时候，就会进入，不做处理，会在playbackBufferEmpty里面缓存之后重新播放
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        
        
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [self monitoringPlayback:playerItem];// 监听播放状态
            
        } else if ([playerItem status] == AVPlayerStatusFailed || [playerItem status] == AVPlayerStatusUnknown) {
            [self stop];
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        [self calculateDownloadProgress:playerItem];
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        
        if (playerItem.isPlaybackBufferEmpty) {
            self.state = TBPlayerStateBuffering;
            [self bufferingSomeSecond];
        }
    }
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem
{
    self.duration = playerItem.duration.value / playerItem.duration.timescale; //视频总时间
    [self.player play];
    [self updateTotolTime:self.duration];
    [self setPlaySliderValue:self.duration];
    
    __weak __typeof(self)weakSelf = self;
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        CGFloat current = playerItem.currentTime.value/playerItem.currentTime.timescale;
        [strongSelf updateCurrentTime:current];
        [strongSelf updateVideoSlider:current];
        if (strongSelf.isPauseByUser == NO) {
            strongSelf.state = TBPlayerStatePlaying;
        }
        
        // 不相等的时候才更新，并发通知，否则seek时会继续跳动
        if (strongSelf.current != current) {
            strongSelf.current = current;
            if (strongSelf.current > strongSelf.duration) {
                strongSelf.duration = strongSelf.current;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kTBPlayerProgressChangedNotification object:nil];
        }
        
    }];

}

- (void)calculateDownloadProgress:(AVPlayerItem *)playerItem
{
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
    CMTime duration = playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    self.loadedProgress = timeInterval / totalDuration;
    [self.videoProgressView setProgress:timeInterval / totalDuration animated:YES];
}
- (void)bufferingSomeSecond
{
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    static BOOL isBuffering = NO;
    if (isBuffering) {
        return;
    }
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        
        [self.player play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.currentPlayerItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSecond];
        }
    });
}

- (void)setLoadedProgress:(CGFloat)loadedProgress
{
    if (_loadedProgress == loadedProgress) {
        return;
    }
    
    _loadedProgress = loadedProgress;
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBPlayerLoadProgressChangedNotification object:nil];
}

- (void)setState:(TBPlayerState)state
{
    if (_state == state) {
        return;
    }
    _state = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBPlayerStateChangedNotification object:nil];
}

#pragma mark - UI界面
- (void)buildVideoNavBar
{
    _navBar.backgroundColor = [self colorWithHex:0x000000 alpha:0.5];
    _navBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
    
    
    
    //当前时间
    if (!self.currentTimeLabel) {
        self.currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [self colorWithHex:0xffffff alpha:1.0];
        _currentTimeLabel.font = [UIFont systemFontOfSize:10.0];
        _currentTimeLabel.frame = CGRectMake(30, 0, 52, 44);
        _currentTimeLabel.textAlignment = NSTextAlignmentRight;
        [_navBar addSubview:_currentTimeLabel];
    }
    
    
    //总时间
    if (!self.totolTimeLabel) {
        self.totolTimeLabel = [[UILabel alloc] init];
        _totolTimeLabel.textColor = [self colorWithHex:0xffffff alpha:1.0];
        _totolTimeLabel.font = [UIFont systemFontOfSize:10.0];
        _totolTimeLabel.frame = CGRectMake(kScreenWidth-52, 0, 52, 44);
        _totolTimeLabel.textAlignment = NSTextAlignmentLeft;
        [_navBar addSubview:_totolTimeLabel];
    }
    
    
    //进度条
    if (!self.videoProgressView) {
        self.videoProgressView = [[UIProgressView alloc] init];
        _videoProgressView.progressTintColor = [self colorWithHex:0xffffff alpha:1.0];  //填充部分颜色
        _videoProgressView.trackTintColor = [self colorWithHex:0xffffff alpha:0.18];   // 未填充部分颜色
        _videoProgressView.frame = CGRectMake(62+30, 21, kScreenWidth-124-44+15, 20);
        _videoProgressView.layer.cornerRadius = 1.5;
        _videoProgressView.layer.masksToBounds = YES;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.5);
        _videoProgressView.transform = transform;
        [_navBar addSubview:_videoProgressView];
    }
    
    
    //滑竿
    if (!self.playSlider) {
        
        self.playSlider = [[UISlider alloc] init];
        _playSlider.frame = CGRectMake(62+30, 0, kScreenWidth-124-44+15, 44);
        [_playSlider setThumbImage:[UIImage imageNamed:@"icon_progress"] forState:UIControlStateNormal];
        _playSlider.minimumTrackTintColor = [UIColor clearColor];
        _playSlider.maximumTrackTintColor = [UIColor clearColor];
        [_playSlider addTarget:self action:@selector(playSliderChange:) forControlEvents:UIControlEventValueChanged]; //拖动滑竿更新时间
        [_playSlider addTarget:self action:@selector(playSliderChangeEnd:) forControlEvents:UIControlEventTouchUpInside];  //松手,滑块拖动停止
        [_playSlider addTarget:self action:@selector(playSliderChangeEnd:) forControlEvents:UIControlEventTouchUpOutside];
        [_playSlider addTarget:self action:@selector(playSliderChangeEnd:) forControlEvents:UIControlEventTouchCancel];
        
        [_navBar addSubview:_playSlider];
    }
    
    //暂停按钮
    if (!self.stopButton) {
        self.stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _stopButton.frame = CGRectMake(0, 0, 44, 44);
        [_stopButton addTarget:self action:@selector(resumeOrPause) forControlEvents:UIControlEventTouchUpInside];
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
        [_navBar addSubview:_stopButton];
    }
    
}



//手指结束拖动，播放器从当前点开始播放，开启滑竿的时间走动
- (void)playSliderChangeEnd:(UISlider *)slider
{
    [self seekToTime:slider.value];
    [self updateCurrentTime:slider.value];
    [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
    [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
}

//手指正在拖动，播放器继续播放，但是停止滑竿的时间走动，并且关闭底部scrollowView的滑动事件
- (void)playSliderChange:(UISlider *)slider
{
    [self updateCurrentTime:slider.value];
}

#pragma mark - 控件拖动
- (void)setPlaySliderValue:(CGFloat)time
{
    _playSlider.minimumValue = 0.0;
    _playSlider.maximumValue = (NSInteger)time;
}
- (void)updateCurrentTime:(CGFloat)time
{
    long videocurrent = ceil(time);
    
    NSString *str = nil;
    if (videocurrent < 3600) {
        str =  [NSString stringWithFormat:@"%02li:%02li",lround(floor(videocurrent/60.f)),lround(floor(videocurrent/1.f))%60];
    } else {
        str =  [NSString stringWithFormat:@"%02li:%02li:%02li",lround(floor(videocurrent/3600.f)),lround(floor(videocurrent%3600)/60.f),lround(floor(videocurrent/1.f))%60];
    }
    
    _currentTimeLabel.text = str;
}

- (void)updateTotolTime:(CGFloat)time
{
    long videoLenth = ceil(time);
    NSString *strtotol = nil;
    if (videoLenth < 3600) {
        strtotol =  [NSString stringWithFormat:@"%02li:%02li",lround(floor(videoLenth/60.f)),lround(floor(videoLenth/1.f))%60];
    } else {
        strtotol =  [NSString stringWithFormat:@"%02li:%02li:%02li",lround(floor(videoLenth/3600.f)),lround(floor(videoLenth%3600)/60.f),lround(floor(videoLenth/1.f))%60];
    }
    
    _totolTimeLabel.text = strtotol;
}


- (void)updateVideoSlider:(CGFloat)currentSecond {
    [self.playSlider setValue:currentSecond animated:YES];
}


#pragma mark - color
- (UIColor*)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0
                           alpha:alphaValue];
}

- (void)dealloc
{
    [self releasePlayer];
}

@end
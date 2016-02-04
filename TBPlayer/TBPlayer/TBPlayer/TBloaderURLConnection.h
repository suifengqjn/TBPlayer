//
//  TBloaderURLConnection.h
//  avplayerSavebufferData
//
//  Created by qianjianeng on 15/9/15.
//  Copyright (c) 2015年 qianjianeng. All rights reserved.
//

/// 这个connenction的功能是把task缓存到本地的临时数据根据播放器需要的 offset和length去取数据并返回给播放器
/// 如果视频文件比较小，就没有必要存到本地，直接用一个变量存储即可
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class TBVideoRequestTask;

@protocol TBloaderURLConnectionDelegate <NSObject>

- (void)didFinishLoadingWithTask:(TBVideoRequestTask *)task;   
- (void)didFailLoadingWithTask:(TBVideoRequestTask *)task WithError:(NSInteger )errorCode;

@end

@interface TBloaderURLConnection : NSURLConnection <AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) TBVideoRequestTask *task;
@property (nonatomic, weak  ) id<TBloaderURLConnectionDelegate> delegate;
- (NSURL *)getSchemeVideoURL:(NSURL *)url;

@end

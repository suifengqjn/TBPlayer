//
//  TBVideoRequestTask.h
//  avplayerSavebufferData
//
//  Created by qianjianeng on 15/9/18.
//  Copyright (c) 2015年 qianjianeng. All rights reserved.
//

/// 这个task的功能是从网络请求数据，并把数据保存到本地的一个临时文件，网络请求结束的时候，如果数据完整，则把数据缓存到指定的路径，不完整就删除
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class TBVideoRequestTask;
@protocol TBVideoRequestTaskDelegate <NSObject>

- (void)task:(TBVideoRequestTask *)task didReceiveVideoLength:(NSUInteger)ideoLength mimeType:(NSString *)mimeType;
- (void)didReceiveVideoDataWithTask:(TBVideoRequestTask *)task;
- (void)didFinishLoadingWithTask:(TBVideoRequestTask *)task;
- (void)didFailLoadingWithTask:(TBVideoRequestTask *)task WithError:(NSInteger )errorCode;

@end

@interface TBVideoRequestTask : NSObject

@property (nonatomic, strong, readonly) NSURL                      *url;
@property (nonatomic, readonly        ) NSUInteger                 offset;

@property (nonatomic, readonly        ) NSUInteger                 videoLength;
@property (nonatomic, readonly        ) NSUInteger                 downLoadingOffset;
@property (nonatomic, strong, readonly) NSString                   * mimeType;
@property (nonatomic, assign)           BOOL                       isFinishLoad;

@property (nonatomic, weak            ) id <TBVideoRequestTaskDelegate> delegate;


- (void)setUrl:(NSURL *)url offset:(NSUInteger)offset;

- (void)cancel;

- (void)continueLoading;

- (void)clearData;


@end

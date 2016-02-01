//
//  TBVideoRequestTask.h
//  avplayerSavebufferData
//
//  Created by stone on 15/9/18.
//  Copyright (c) 2015年 qianjianeng. All rights reserved.
//

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

//
//  TBloaderURLConnection.h
//  avplayerSavebufferData
//
//  Created by qianjianeng on 15/9/15.
//  Copyright (c) 2015年 qianjianeng. All rights reserved.
//

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

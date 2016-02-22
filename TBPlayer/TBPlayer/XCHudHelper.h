//
//  XCHudHelper.h
//
//  Created by TopDev on 10/23/14.
//  Copyright (c) 2014 TopDev. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MBProgressHUD.h"

@interface XCHudHelper : NSObject

@property(nonatomic, strong) MBProgressHUD *hud;

// 单例
+ (XCHudHelper *)sharedInstance;

// 在window上显示菊花转hud
- (void)showHudAcitivityOnWindow;

// 在window上显示hud
// 参数：
// caption:标题
// bActive：是否显示转圈动画
// time：自动消失时间，如果为0，则不自动消失

- (void)showHudOnWindow:(NSString *)caption
                  image:(UIImage *)image
              acitivity:(BOOL)bAcitve
           autoHideTime:(NSTimeInterval)time;

// 在当前的view上显示hud
// 参数：
// view：要添加hud的view
// caption:标题
// image:图片
// bActive：是否显示转圈动画
// time：自动消失时间，如果为0，则不自动消失
- (void)showHudOnView:(UIView *)view
              caption:(NSString *)caption
                image:(UIImage *)image
            acitivity:(BOOL)bAcitve
         autoHideTime:(NSTimeInterval)time;

- (void)setCaption:(NSString *)caption;

// 隐藏hud
- (void)hideHud;

- (void)hideHudAfter:(NSTimeInterval)time;


//成功，失败，普通信息
+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;
+ (void)showMessage:(NSString *)message;
+ (void)hideHUD;

@end

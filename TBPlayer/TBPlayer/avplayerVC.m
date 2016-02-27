//
//  avplayerVC.m
//  TBPlayer
//
//  Created by qianjianeng on 16/2/27.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "avplayerVC.h"
#import "TBPlayer.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


@interface avplayerVC ()

@property (nonatomic, strong) TBPlayer *player;
@property (nonatomic, strong) UIView *showView;
@end

@implementation avplayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showView = [[UIView alloc] init];
    self.showView.frame = CGRectMake(0, 0, kScreenHeight, kScreenWidth);
    [self.view addSubview:self.showView];
    
    
    
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *movePath =  [document stringByAppendingPathComponent:@"保存数据.mp4"];
    
    NSURL *localURL = [NSURL fileURLWithPath:movePath];
    
    NSURL *url2 = [NSURL URLWithString:@"http://zyvideo1.oss-cn-qingdao.aliyuncs.com/zyvd/7c/de/04ec95f4fd42d9d01f63b9683ad0"];
    
    NSURL *url3 = url2;
    [[TBPlayer sharedInstance] playWithUrl:localURL showView:self.showView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    
    [self.showView addGestureRecognizer:tap];
    
    self.showView.transform=CGAffineTransformMakeRotation(M_PI/2);
    self.showView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
}


- (void)quanping
{
    self.showView.frame = CGRectMake(0, 0, kScreenHeight, kScreenWidth);
    [self.player updateFrame];
    self.showView.transform=CGAffineTransformMakeRotation(M_PI/2);
    self.showView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
}

- (void)tapClick
{
    
    
    self.showView.transform = CGAffineTransformIdentity;
    
    [self.player updateFrame];
}

@end

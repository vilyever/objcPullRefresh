//
//  VDPullRefreshManager.h
//  objcPullRefresh
//
//  Created by Deng on 16/7/20.
//  Copyright © Deng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDPullRefreshElement.h"
#import "VDDefaultPullingView.h"


@class VDPullRefreshManager;


@interface VDPullRefreshManager : NSObject

#pragma mark Public Method
+ (VDPullRefreshManager *)sharedManager;
+ (void)setupDefaultPullOrientation:(VDPullRefreshOrientation)defaultPullOrientation;
+ (void)setupDefaultHeaderPullingViewHeight:(CGFloat)defaultHeaderPullingViewHeight;
+ (void)setupDefaultTrailerPullingViewHeight:(CGFloat)defaultTrailerPullingViewHeight;
+ (void)setupDefaultPullingHeaderViewBuilder:(UIView<VDPullRefreshPullingHeaderView> *(^)(void))defaultPullingHeaderViewBuilder;
+ (void)setupDefaultPullingTrailerViewBuilder:(UIView<VDPullRefreshPullingTrailerView> *(^)(void))defaultPullingTrailerViewBuilder;

+ (UIView<VDPullRefreshPullingHeaderView> *)newDefaultHeaderPullingView;
+ (UIView<VDPullRefreshPullingTrailerView> *)newDefaultTrailerPullingView;

#pragma mark Properties
@property (nonatomic, assign) VDPullRefreshOrientation defaultPullOrientation; // default is vertical
@property (nonatomic, assign) CGFloat defaultHeaderPullingViewHeight; // default is 60.0f
@property (nonatomic, assign) CGFloat defaultTrailerPullingViewHeight; // default is 60.0f
@property (nonatomic, strong) UIView<VDPullRefreshPullingHeaderView> *(^defaultPullingHeaderViewBuilder)(void);
@property (nonatomic, strong) UIView<VDPullRefreshPullingTrailerView> *(^defaultPullingTrailerViewBuilder)(void);

#pragma mark Private Method

@end

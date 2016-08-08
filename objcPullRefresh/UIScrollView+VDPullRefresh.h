//
//  UIScrollView+VDPullRefresh.h
//  objcTemp
//
//  Created by Deng on 16/7/20.
//  Copyright © Deng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VDPullRefreshManager.h"
#import "VDPullRefreshElement.h"


@interface UIScrollView (VDPullRefresh)

#pragma mark Public Method
- (void)vd_enablePullRefreshHeaderWithAction:(void(^)(void))actionBlock;
- (void)vd_disablePullRefreshHeader;
- (void)vd_enablePullRefreshTrailerWithAction:(void(^)(void))actionBlock;
- (void)vd_disablePullRefreshTrailder;

- (void)vd_startPullRefreshHeaderRefreshing;
- (void)vd_stopPullRefreshHeaderRefreshing;
- (void)vd_startPullRefreshTrailerRefreshing;
- (void)vd_stopPullRefreshTrailerRefreshing;

- (void)vd_setPullRefreshHeaderView:(UIView<VDPullRefreshPullingHeaderView> *)view;
- (void)vd_setPullRefreshTrailerView:(UIView<VDPullRefreshPullingTrailerView> *)view;

#pragma mark Properties
@property (nonatomic, strong) VDPullRefreshElement *vd_pullRefreshElement;
@property (nonatomic, weak) id<VDPullRefreshDelegate> vd_pullRefreshDelegate;
@property (nonatomic, assign) VDPullRefreshOrientation vd_pullOrientation;
@property (nonatomic, assign) BOOL vd_isPullRefreshHeaderEnable;
@property (nonatomic, assign) BOOL vd_isPullRefreshTrailerEnable;
@property (nonatomic, assign) BOOL vd_isPullRefreshHeaderRefreshing;
@property (nonatomic, assign) BOOL vd_isPullRefreshTrailerRefreshing;
@property (nonatomic, assign) BOOL vd_isPullRefreshAnimatingPullbackEnable;

@end

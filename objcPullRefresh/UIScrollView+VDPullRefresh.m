//
//  UIScrollView+VDPullRefresh.m
//  objcTemp
//
//  Created by Deng on 16/7/20.
//  Copyright © Deng. All rights reserved.
//

#import "UIScrollView+VDPullRefresh.h"

#import <objc/runtime.h>
//#import "objcTemp.h"
//@import objcTemp;


@implementation UIScrollView (VDPullRefresh)

@dynamic vd_pullRefreshElement;
@dynamic vd_pullRefreshDelegate;
@dynamic vd_pullOrientation;
@dynamic vd_isPullRefreshHeaderEnable;
@dynamic vd_isPullRefreshTrailerEnable;
@dynamic vd_isPullRefreshHeaderRefreshing;
@dynamic vd_isPullRefreshTrailerRefreshing;

#pragma mark Public Method
- (void)vd_enablePullRefreshHeaderWithAction:(void(^)(void))actionBlock {
    self.vd_isPullRefreshHeaderEnable = YES;
    self.vd_pullRefreshElement.headerRefreshActionBlock = actionBlock;
}

- (void)vd_disablePullRefreshHeader {
    self.vd_isPullRefreshHeaderEnable = NO;
}

- (void)vd_enablePullRefreshTrailerWithAction:(void(^)(void))actionBlock {
    self.vd_isPullRefreshTrailerEnable = YES;
    self.vd_pullRefreshElement.trailerRefreshActionBlock = actionBlock;
}

- (void)vd_disablePullRefreshTrailder {
    self.vd_isPullRefreshTrailerEnable = NO;
}

- (void)vd_startPullRefreshHeaderRefreshing {
    self.vd_isPullRefreshHeaderRefreshing = YES;
}

- (void)vd_stopPullRefreshHeaderRefreshing {
    self.vd_isPullRefreshHeaderRefreshing = NO;
}

- (void)vd_startPullRefreshTrailerRefreshing {
    self.vd_isPullRefreshTrailerRefreshing = YES;
}

- (void)vd_stopPullRefreshTrailerRefreshing {
    self.vd_isPullRefreshTrailerRefreshing = NO;
}

- (void)vd_setPullRefreshHeaderView:(UIView<VDPullRefreshPullingHeaderView> *)view {
    self.vd_pullRefreshElement.headerPullingView = view;
}

- (void)vd_setPullRefreshTrailerView:(UIView<VDPullRefreshPullingTrailerView> *)view {
    self.vd_pullRefreshElement.trailerPullingView = view;
}

#pragma mark Private Method
- (VDPullRefreshElement *)vd_pullRefreshElement {
    VDPullRefreshElement *element = objc_getAssociatedObject(self, @selector(vd_pullRefreshElement));
    if (!element) {
        element = [[VDPullRefreshElement alloc] init];
        element.scrollView = self;
        element.pullOrientation = [VDPullRefreshManager sharedManager].defaultPullOrientation;
        element.defaultHeaderPullingViewHeight = [VDPullRefreshManager sharedManager].defaultHeaderPullingViewHeight;
        element.defaultTrailerPullingViewHeight = [VDPullRefreshManager sharedManager].defaultTrailerPullingViewHeight;
                
        objc_setAssociatedObject(self, @selector(vd_pullRefreshElement), element, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return element;
}

- (void)setVd_pullRefreshDelegate:(id<VDPullRefreshDelegate>)vd_pullRefreshDelegate {
    self.vd_pullRefreshElement.pullRefreshDelegate = vd_pullRefreshDelegate;
}

- (id<VDPullRefreshDelegate>)vd_pullRefreshDelegate {
    return self.vd_pullRefreshElement.pullRefreshDelegate;
}

- (void)setVd_pullOrientation:(VDPullRefreshOrientation)vd_pullOrientation {
    self.vd_pullRefreshElement.pullOrientation = vd_pullOrientation;
}

- (VDPullRefreshOrientation)vd_pullOrientation {
    return self.vd_pullRefreshElement.pullOrientation;
}

- (void)setVd_isPullRefreshHeaderEnable:(BOOL)vd_isPullRefreshHeaderEnable {
    if (vd_isPullRefreshHeaderEnable && !self.vd_pullRefreshElement.headerPullingView) {
        self.vd_pullRefreshElement.headerPullingView = [VDPullRefreshManager newDefaultHeaderPullingView];
    }
    self.vd_pullRefreshElement.isHeaderPullingEnabled = vd_isPullRefreshHeaderEnable;
}

- (BOOL)vd_isPullRefreshHeaderEnable {
    return self.vd_pullRefreshElement.isHeaderPullingEnabled;
}

- (void)setVd_isPullRefreshTrailerEnable:(BOOL)vd_isPullRefreshTrailerEnable {
    if (vd_isPullRefreshTrailerEnable && !self.vd_pullRefreshElement.trailerPullingView) {
        self.vd_pullRefreshElement.trailerPullingView = [VDPullRefreshManager newDefaultTrailerPullingView];
    }
    self.vd_pullRefreshElement.isTrailerPullingEnabled = vd_isPullRefreshTrailerEnable;
}

- (BOOL)vd_isPullRefreshTrailerEnable {
    return self.vd_pullRefreshElement.isTrailerPullingEnabled;
}

- (void)setVd_isPullRefreshHeaderRefreshing:(BOOL)vd_isPullRefreshHeaderRefreshing {
    self.vd_pullRefreshElement.isHeaderRefreshing = vd_isPullRefreshHeaderRefreshing;
}

- (BOOL)vd_isPullRefreshHeaderRefreshing {
    return self.vd_pullRefreshElement.isHeaderRefreshing;
}

- (void)setVd_isPullRefreshTrailerRefreshing:(BOOL)vd_isPullRefreshTrailerRefreshing {
    self.vd_pullRefreshElement.isTrailerRefreshing = vd_isPullRefreshTrailerRefreshing;
}

- (BOOL)vd_isPullRefreshTrailerRefreshing {
    return self.vd_pullRefreshElement.isTrailerRefreshing;
}

- (void)setVd_isPullRefreshAnimatingPullbackEnable:(BOOL)vd_isPullRefreshAnimatingPullbackEnable {
    self.vd_pullRefreshElement.animatingPullbackEnable = vd_isPullRefreshAnimatingPullbackEnable;
}

- (BOOL)vd_isPullRefreshAnimatingPullbackEnable {
    return self.vd_pullRefreshElement.animatingPullbackEnable;
}

@end

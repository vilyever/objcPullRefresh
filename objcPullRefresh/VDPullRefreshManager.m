//
//  VDPullRefreshManager.m
//  objcPullRefresh
//
//  Created by Deng on 16/7/20.
//  Copyright © Deng. All rights reserved.
//

#import "VDPullRefreshManager.h"


@interface VDPullRefreshManager ()

- (void)__i__initVDPullRefreshManager;

@end


@implementation VDPullRefreshManager

#pragma mark Constructor
+ (VDPullRefreshManager *)sharedManager {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    } );
    
    return _sharedInstance;
}

#pragma mark Public Method
+ (void)setupDefaultPullOrientation:(VDPullRefreshOrientation)defaultPullOrientation {
    [self sharedManager].defaultPullOrientation = defaultPullOrientation;
}

+ (void)setupDefaultHeaderPullingViewHeight:(CGFloat)defaultHeaderPullingViewHeight {
    [self sharedManager].defaultHeaderPullingViewHeight = defaultHeaderPullingViewHeight;
}

+ (void)setupDefaultTrailerPullingViewHeight:(CGFloat)defaultTrailerPullingViewHeight {
    [self sharedManager].defaultTrailerPullingViewHeight = defaultTrailerPullingViewHeight;
}

+ (void)setupDefaultPullingHeaderViewBuilder:(UIView<VDPullRefreshPullingHeaderView> *(^)(void))defaultPullingHeaderViewBuilder {
    [self sharedManager].defaultPullingHeaderViewBuilder = defaultPullingHeaderViewBuilder;
}

+ (void)setupDefaultPullingTrailerViewBuilder:(UIView<VDPullRefreshPullingTrailerView> *(^)(void))defaultPullingTrailerViewBuilder {
    [self sharedManager].defaultPullingTrailerViewBuilder = defaultPullingTrailerViewBuilder;
}

+ (UIView<VDPullRefreshPullingHeaderView> *)newDefaultHeaderPullingView {
    if ([self sharedManager].defaultPullingHeaderViewBuilder) {
        return [self sharedManager].defaultPullingHeaderViewBuilder();
    }
    
    return [VDDefaultPullingView pullingHeaderView];
}

+ (UIView<VDPullRefreshPullingTrailerView> *)newDefaultTrailerPullingView {
    if ([self sharedManager].defaultPullingTrailerViewBuilder) {
        return [self sharedManager].defaultPullingTrailerViewBuilder();
    }
    
    return [VDDefaultPullingView pullingTrailerView];
}

#pragma mark Properties


#pragma mark Overrides
- (instancetype)init {
    self = [super init];
    
    [self __i__initVDPullRefreshManager];
    
    return self;
}

- (void)dealloc {
    
}


#pragma mark Delegates


#pragma mark Private Method
- (void)__i__initVDPullRefreshManager {
    _defaultPullOrientation = VDPullRefreshOrientationVertical;
    _defaultHeaderPullingViewHeight = 60.0f;
    _defaultTrailerPullingViewHeight = 60.0f;
}

@end

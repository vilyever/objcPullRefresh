//
//  VDPullRefreshManager.m
//  objcTemp
//
//  Created by Deng on 16/7/20.
//  Copyright © Deng. All rights reserved.
//

#import "VDPullRefreshManager.h"


@interface VDPullRefreshManager ()


@end


@implementation VDPullRefreshManager

#pragma mark Public Method
+ (VDPullRefreshManager *)sharedManager {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [ [ [self class] alloc] init];
    } );
    
    return _sharedInstance;
}

+ (void)setupDefaultPullOrientation:(VDPullRefreshOrientation)defaultPullOrientation {
    [self sharedManager].defaultPullOrientation = defaultPullOrientation;
}

+ (void)setupDefaultHeaderPullingViewHeight:(CGFloat)defaultHeaderPullingViewHeight {
    [self sharedManager].defaultHeaderPullingViewHeight = defaultHeaderPullingViewHeight;
}

+ (void)setupDefaultTrailerPullingViewHeight:(CGFloat)defaultTrailerPullingViewHeight {
    [self sharedManager].defaultTrailerPullingViewHeight = defaultTrailerPullingViewHeight;
}

+ (void)setupDefaultPullingHeaderViewBuilderBlock:(UIView<VDPullRefreshPullingHeaderView> *(^)(void))defaultPullingHeaderViewBuilderBlock {
    [self sharedManager].defaultPullingHeaderViewBuilderBlock = defaultPullingHeaderViewBuilderBlock;
}

+ (void)setupDefaultPullingTrailerViewBuilderBlock:(UIView<VDPullRefreshPullingTrailerView> *(^)(void))defaultPullingTrailerViewBuilderBlock {
    [self sharedManager].defaultPullingTrailerViewBuilderBlock = defaultPullingTrailerViewBuilderBlock;
}

+ (UIView<VDPullRefreshPullingHeaderView> *)newDefaultHeaderPullingView {
    if ([self sharedManager].defaultPullingHeaderViewBuilderBlock) {
        return [self sharedManager].defaultPullingHeaderViewBuilderBlock();
    }
    
    return [VDDefaultPullingView pullingHeaderView];
}

+ (UIView<VDPullRefreshPullingTrailerView> *)newDefaultTrailerPullingView {
    if ([self sharedManager].defaultPullingTrailerViewBuilderBlock) {
        return [self sharedManager].defaultPullingTrailerViewBuilderBlock();
    }
    
    return [VDDefaultPullingView pullingTrailerView];
}

#pragma mark Properties


#pragma mark Overrides
- (instancetype)init {
    self = [super init];
    
    [self internalInitVDPullRefreshManager];
    
    return self;
}

- (void)dealloc {
    
}


#pragma mark Delegates


#pragma mark Private Method
- (void)internalInitVDPullRefreshManager {
    _defaultPullOrientation = VDPullRefreshOrientationVertical;
    _defaultHeaderPullingViewHeight = 60.0f;
    _defaultTrailerPullingViewHeight = 60.0f;
}

@end

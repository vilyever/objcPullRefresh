//
//  VDPullRefreshElement.h
//  objcPullRefresh
//
//  Created by Deng on 16/7/20.
//  Copyright © Deng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VDPullRefreshOrientation) {
    VDPullRefreshOrientationVertical,
    VDPullRefreshOrientationHorizontal,
};

typedef NS_ENUM(NSInteger, VDPullRefreshLayoutType) {
    VDPullRefreshLayoutTypeHide, // hide this pulling view, often when disable
    VDPullRefreshLayoutTypeShowAndLayoutInsideWhenRefreshing, // show this pulling view, layout inside scrollView when refreshing
    VDPullRefreshLayoutTypeShowAndLayoutInside,  // show this pulling view, layout inside scrollView in any state
    VDPullRefreshLayoutTypeShowAndLayoutOutside,  // show this pulling view, layout outside scrollView in any state
};

@class VDPullRefreshElement;


@protocol VDPullRefreshPullingView <NSObject>

@required


@optional
/**
 *  when refreshing, the pulling view height to display
 *
 *  @return pulling view height, default is 60.0f
 */
- (CGFloat)pullingViewHeightForPullRefreshElement:(VDPullRefreshElement *)element;

/**
 *  when scrollView endDraaging offset larger or equal than this will start refreshing
 *
 *  @return min offset to start refreshing, default is same to @selector(rp_pullingViewHeight)
 */
- (CGFloat)triggerRefreshingOffsetForPullRefreshElement:(VDPullRefreshElement *)element;

/**
 *  should trigger refreshing when dragging
 *  header is trigger when drag end in common,
 *  trailer may want to trigger when dragging to start load more
 *  default is NO
 */
- (BOOL)shouldTriggerOnDraggingForPullRefreshElement:(VDPullRefreshElement *)element;

// TODO: support this in element
/**
 *  retain duration for end refreshing to show message
 *
 *  @return default is 0
 */
- (NSTimeInterval)retainDurationForEndRefreshingForPullRefreshElement:(VDPullRefreshElement *)element;

// TODO: support this in element
/**
 *  pull down/up animate duration for no dragging to change refreshing, like end refreshing, start refreshing in code
 *
 *  @return default is 0.3
 */
- (NSTimeInterval)triggerDurationForNoDraggingRefreshingForPullRefreshElement:(VDPullRefreshElement *)element;

/**
 *  update UI
 *
 *  @param enabled       scroll is enabled to trigger pull refresh, it's common that hide the pulling view when disable with return NO, but return YES to display a logo or info when disalbe is also good
 *  @param isRefreshing  is refreshing now, always NO when disable
 *  @param pullingOffset current pulling offset, positive offset means reveal offset
 *
 *  @return layout type for scroll view to layout
 */
- (VDPullRefreshLayoutType)layoutTypeForPullRefreshElement:(VDPullRefreshElement *)element withEnabled:(BOOL)enabled refreshing:(BOOL)isRefreshing pullingOffset:(CGFloat)pullingOffset;

// TODO: add retain duration for end refreshing to show message
// TODO: add collapse duration for collapse animation if scrollView's state can perform animtion

@end

@protocol VDPullRefreshPullingHeaderView <VDPullRefreshPullingView>

@optional

@end

@protocol VDPullRefreshPullingTrailerView <VDPullRefreshPullingView>

@optional
/**
 *  implement this method will cover @selector(rp_triggerRefreshingOffset)
 *  will return a multiplier, min offset to start refreshing is -(scrollView.pageSize * multiplier)
 *  @return multiplier
 */
- (CGFloat)triggerRefreshingOffsetByScrollViewPageSizeMultiplierForPullRefreshElement:(VDPullRefreshElement *)element;

@end


@protocol VDPullRefreshDelegate <NSObject>

@optional
- (void)pullRefreshElement:(VDPullRefreshElement *)element headerPullingEnableStateChange:(BOOL)enabled;
- (void)pullRefreshElement:(VDPullRefreshElement *)element headerRefreshingStateChange:(BOOL)refreshing;
- (void)pullRefreshElement:(VDPullRefreshElement *)element trailerPullingEnableStateChange:(BOOL)enabled;
- (void)pullRefreshElement:(VDPullRefreshElement *)element trailerRefreshingStateChange:(BOOL)refreshing;

@end


@interface VDPullRefreshElement : NSObject

#pragma mark Public Method


#pragma mark Properties
@property (nonatomic, weak) id<VDPullRefreshDelegate> pullRefreshDelegate;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView<VDPullRefreshPullingHeaderView> *headerPullingView;
@property (nonatomic, strong) UIView<VDPullRefreshPullingTrailerView> *trailerPullingView;
@property (nonatomic, assign) VDPullRefreshOrientation pullOrientation;
@property (nonatomic, assign) CGFloat defaultHeaderPullingViewHeight;
@property (nonatomic, assign) CGFloat defaultTrailerPullingViewHeight;
@property (nonatomic, assign) BOOL isHeaderPullingEnabled;
@property (nonatomic, assign) BOOL isHeaderRefreshing;
@property (nonatomic, assign) BOOL isTrailerPullingEnabled;
@property (nonatomic, assign) BOOL isTrailerRefreshing;
@property (nonatomic, assign) BOOL animatingPullbackEnable;

@property (nonatomic, assign, readonly) VDPullRefreshLayoutType headerLayoutType;
@property (nonatomic, assign, readonly) VDPullRefreshLayoutType trailerLayoutType;

@property (nonatomic, strong) void(^headerRefreshAction)(void);
@property (nonatomic, strong) void(^trailerRefreshAction)(void);

#pragma mark Private Method


@end

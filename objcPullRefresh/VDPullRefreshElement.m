//
//  VDPullRefreshElement.m
//  objcPullRefresh
//
//  Created by Deng on 16/7/20.
//  Copyright © Deng. All rights reserved.
//

#import "VDPullRefreshElement.h"
#import <objcKeyPath/objcKeyPath.h>


@interface VDPullRefreshElement () <UIScrollViewDelegate>

- (void)__i__initVDPullRefreshElement;

- (void)__i__addScrollView:(UIScrollView *)scrollView;
- (void)__i__removeScrollView:(UIScrollView *)scrollView;

- (void)__i__addHeaderView;
- (void)__i__addTrailerView;

- (CGFloat)__i__getHeaderViewHeight;
- (CGFloat)__i__getHeaderTriggerOffset;

- (CGFloat)__i__getTrailerViewHeight;
- (CGFloat)__i__getTrailerTriggerOffset;

- (void)__i__layoutHeaderView;
- (void)__i__layoutTrailerView;

- (void)__i__updatRefreshingState:(BOOL)isEndDragging;

- (void)__i__updateScrollViewLayout;

@property (nonatomic, assign, readwrite) VDPullRefreshLayoutType headerLayoutType;
@property (nonatomic, assign, readwrite) VDPullRefreshLayoutType trailerLayoutType;

@property (nonatomic, assign) BOOL isScrollViewDragging;
@property (nonatomic, assign) UIEdgeInsets currentOffsetEdgeInsets;

@end


@implementation VDPullRefreshElement

#pragma mark Public Method


#pragma mark Properties
- (void)setScrollView:(UIScrollView *)scrollView {
    if (_scrollView != scrollView) {
        if (_scrollView) {
            [self __i__removeScrollView:_scrollView];
        }
        
        _scrollView = scrollView;
        
        if (_scrollView) {
            [self __i__addScrollView:_scrollView];
            [self __i__addHeaderView];
            [self __i__addTrailerView];
        }
    }
}

- (void)setHeaderPullingView:(UIView<VDPullRefreshPullingHeaderView> *)headerPullingView {
    if (_headerPullingView != headerPullingView) {
        [_headerPullingView removeFromSuperview];
        _headerPullingView = headerPullingView;
        [self __i__addHeaderView];
    }
}

- (void)setTrailerPullingView:(UIView<VDPullRefreshPullingTrailerView> *)trailerPullingView {
    if (_trailerPullingView != trailerPullingView) {
        [_trailerPullingView removeFromSuperview];
        _trailerPullingView = trailerPullingView;
        [self __i__addTrailerView];
    }
}

- (void)setPullOrientation:(VDPullRefreshOrientation)pullOrientation {
    if (_pullOrientation != pullOrientation) {
        _pullOrientation = pullOrientation;
        self.isHeaderRefreshing = NO;
        self.isTrailerRefreshing = NO;
        [self __i__layoutHeaderView];
        [self __i__layoutTrailerView];
        [self __i__updateScrollViewLayout];
    }
}

- (void)setIsHeaderPullingEnabled:(BOOL)isHeaderPullingEnabled {
    if (_isHeaderPullingEnabled != isHeaderPullingEnabled) {
        _isHeaderPullingEnabled = isHeaderPullingEnabled;
        if (!_isHeaderPullingEnabled) {
            [self __i__setIsHeaderRefreshing:NO];
        }
        [self __i__updateScrollViewLayout];
        
        if ([self.pullRefreshDelegate respondsToSelector:@selector(pullRefreshElement:headerPullingEnableStateChange:)]) {
            [self.pullRefreshDelegate pullRefreshElement:self headerPullingEnableStateChange:_isHeaderPullingEnabled];
        }
    }
}

- (void)setIsHeaderRefreshing:(BOOL)isHeaderRefreshing {
    [self __i__setIsHeaderRefreshing:isHeaderRefreshing];
    [self __i__updateScrollViewLayout];
}

- (void)__i__setIsHeaderRefreshing:(BOOL)isHeaderRefreshing {
    if (isHeaderRefreshing && !self.isHeaderPullingEnabled) {
        return;
    }
    
    if (_isHeaderRefreshing != isHeaderRefreshing) {
        _isHeaderRefreshing = isHeaderRefreshing;
        
        if (_isHeaderRefreshing
            && self.headerRefreshAction) {
            self.headerRefreshAction();
        }
        
        if ([self.pullRefreshDelegate respondsToSelector:@selector(pullRefreshElement:headerRefreshingStateChange:)]) {
            [self.pullRefreshDelegate pullRefreshElement:self headerRefreshingStateChange:_isHeaderRefreshing];
        }
    }
}

- (void)setIsTrailerPullingEnabled:(BOOL)isTrailerPullingEnabled {
    if (_isTrailerPullingEnabled != isTrailerPullingEnabled) {
        _isTrailerPullingEnabled = isTrailerPullingEnabled;
        if (!_isTrailerPullingEnabled) {
            [self __i__setIsTrailerRefreshing:NO];
        }
        [self __i__updateScrollViewLayout];
        
        if ([self.pullRefreshDelegate respondsToSelector:@selector(pullRefreshElement:trailerPullingEnableStateChange:)]) {
            [self.pullRefreshDelegate pullRefreshElement:self trailerPullingEnableStateChange:_isTrailerPullingEnabled];
        }
    }
}

- (void)setIsTrailerRefreshing:(BOOL)isTrailerRefreshing {
    [self __i__setIsTrailerRefreshing:isTrailerRefreshing];
    [self __i__updateScrollViewLayout];
}

- (void)__i__setIsTrailerRefreshing:(BOOL)isTrailerRefreshing {
    if (isTrailerRefreshing && !self.isTrailerPullingEnabled) {
        return;
    }
    
    if (_isTrailerRefreshing != isTrailerRefreshing) {
        _isTrailerRefreshing = isTrailerRefreshing;
        if (_isTrailerRefreshing
            && self.trailerRefreshAction) {
            self.trailerRefreshAction();
        }
        
        if ([self.pullRefreshDelegate respondsToSelector:@selector(pullRefreshElement:trailerRefreshingStateChange:)]) {
            [self.pullRefreshDelegate pullRefreshElement:self trailerRefreshingStateChange:_isTrailerRefreshing];
        }
    }
}

#pragma mark Overrides
- (instancetype)init {
    self = [super init];
    
    [self __i__initVDPullRefreshElement];
    
    return self;
}

- (void)dealloc {
    [self __i__removeScrollView:self.scrollView];
    self.scrollView = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [self __i__layoutHeaderView];
    [self __i__layoutTrailerView];
    
    if ([keyPath isEqualToString:VDKeyPath(self.scrollView, contentOffset)]
        || [keyPath isEqualToString:VDKeyPath(self.scrollView, contentSize)]) {
        BOOL isEndDragging = self.isScrollViewDragging && !self.scrollView.isDragging;
        self.isScrollViewDragging = self.scrollView.isDragging;
        
        [self __i__updatRefreshingState:isEndDragging];
    }
}

#pragma mark Delegates

#pragma mark Private Method
- (void)__i__initVDPullRefreshElement {
    _headerLayoutType = VDPullRefreshLayoutTypeShowAndLayoutInsideWhenRefreshing;
    _trailerLayoutType = VDPullRefreshLayoutTypeShowAndLayoutInsideWhenRefreshing;
    _isScrollViewDragging = NO;
    _currentOffsetEdgeInsets = UIEdgeInsetsZero;
    _defaultHeaderPullingViewHeight = 60.0f;
    _defaultTrailerPullingViewHeight = 60.0f;
    _animatingPullbackEnable = YES;
}

- (void)__i__addScrollView:(UIScrollView *)scrollView {
    [scrollView addObserver:self forKeyPath:VDKeyPath(_scrollView, bounds) options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [scrollView addObserver:self forKeyPath:VDKeyPath(_scrollView, contentOffset) options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [scrollView addObserver:self forKeyPath:VDKeyPath(_scrollView, contentSize) options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

- (void)__i__removeScrollView:(UIScrollView *)scrollView {
    if (self.headerPullingView) {
        [self.headerPullingView removeFromSuperview];
    }
    if (self.trailerPullingView) {
        [self.trailerPullingView removeFromSuperview];
    }
    [scrollView removeObserver:self forKeyPath:VDKeyPath(self.scrollView, bounds)];
    [scrollView removeObserver:self forKeyPath:VDKeyPath(self.scrollView, contentOffset)];
    [scrollView removeObserver:self forKeyPath:VDKeyPath(self.scrollView, contentSize)];
}

- (void)__i__addHeaderView {
    if (self.headerPullingView.superview == self.scrollView) {
        return;
    }
    if (self.scrollView && self.headerPullingView) {
        [self.headerPullingView removeFromSuperview];
        [self.scrollView addSubview:self.headerPullingView];
        [self __i__layoutHeaderView];
    }

    self.isHeaderPullingEnabled = self.headerPullingView != nil;
}

- (void)__i__addTrailerView {
    if (self.trailerPullingView.superview == self.scrollView) {
        return;
    }
    if (self.scrollView && self.trailerPullingView) {
        [self.trailerPullingView removeFromSuperview];
        [self.scrollView addSubview:self.trailerPullingView];
        [self __i__layoutTrailerView];
    }
    
    self.isTrailerPullingEnabled = self.trailerPullingView != nil;
}

- (CGFloat)__i__getHeaderViewHeight {
    if (!self.headerPullingView) {
        return 0.0f;
    }
    
    CGFloat height = self.defaultHeaderPullingViewHeight;
    if ([self.headerPullingView respondsToSelector:@selector(pullingViewHeightForPullRefreshElement:)]) {
        height = [self.headerPullingView pullingViewHeightForPullRefreshElement:self];
    }
    
    return height;
}

- (CGFloat)__i__getHeaderTriggerOffset {
    if (!self.headerPullingView) {
        return HUGE_VALF;
    }
    
    CGFloat offset = [self __i__getHeaderViewHeight];
    if ([self.headerPullingView respondsToSelector:@selector(triggerRefreshingOffsetForPullRefreshElement:)]) {
        offset = [self.headerPullingView triggerRefreshingOffsetForPullRefreshElement:self];
    }
    
    return offset;
}

- (CGFloat)__i__getTrailerViewHeight {
    if (!self.trailerPullingView) {
        return 0.0f;
    }
    
    CGFloat height = self.defaultTrailerPullingViewHeight;
    if ([self.trailerPullingView respondsToSelector:@selector(pullingViewHeightForPullRefreshElement:)]) {
        height = [self.trailerPullingView pullingViewHeightForPullRefreshElement:self];
    }
    
    return height;
}

- (CGFloat)__i__getTrailerTriggerOffset {
    if (!self.trailerPullingView) {
        return HUGE_VALF;
    }
    
    CGFloat offset = [self __i__getTrailerViewHeight];
    if ([self.trailerPullingView respondsToSelector:@selector(triggerRefreshingOffsetForPullRefreshElement:)]) {
        offset = [self.trailerPullingView triggerRefreshingOffsetForPullRefreshElement:self];
    }
    if ([self.trailerPullingView respondsToSelector:@selector(triggerRefreshingOffsetByScrollViewPageSizeMultiplierForPullRefreshElement:)]) {
        offset = -self.scrollView.bounds.size.height * [self.trailerPullingView triggerRefreshingOffsetByScrollViewPageSizeMultiplierForPullRefreshElement:self];
    }
    
    return offset;
}

- (void)__i__layoutHeaderView {
    if (self.headerPullingView) {
        CGFloat height = [self __i__getHeaderViewHeight];
        switch (self.pullOrientation) {
            case VDPullRefreshOrientationVertical: {
                self.headerPullingView.frame = CGRectMake(self.scrollView.contentOffset.x, -height, self.scrollView.bounds.size.width, height);
                break;
            }
            case VDPullRefreshOrientationHorizontal: {
                self.headerPullingView.frame = CGRectMake(-height, self.scrollView.contentOffset.y, height, self.scrollView.bounds.size.height);
                break;
            }
        }
    }
}

- (void)__i__layoutTrailerView {
    if (self.trailerPullingView) {
        CGFloat height = [self __i__getTrailerViewHeight];
        
        CGFloat contentWith = MAX(self.scrollView.contentSize.width, self.scrollView.bounds.size.width);
        CGFloat contentHeight = MAX(self.scrollView.contentSize.height, self.scrollView.bounds.size.height);
        
        switch (self.pullOrientation) {
            case VDPullRefreshOrientationVertical: {
                self.trailerPullingView.frame = CGRectMake(self.scrollView.contentOffset.x, contentHeight, self.scrollView.bounds.size.width, height);
                break;
            }
            case VDPullRefreshOrientationHorizontal: {
                self.trailerPullingView.frame = CGRectMake(contentWith, self.scrollView.contentOffset.y, height, self.scrollView.bounds.size.height);
                break;
            }
        }
    }
}

- (void)__i__updatRefreshingState:(BOOL)isEndDragging {
    if (!self.scrollView) {
        return;
    }
    
    if (!self.headerPullingView && !self.trailerPullingView) {
        return;
    }
    
    if (self.isHeaderRefreshing || self.isTrailerRefreshing) {
        return;
    }
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGFloat contentWith = MAX(self.scrollView.contentSize.width, self.scrollView.bounds.size.width);
    CGFloat contentHeight = MAX(self.scrollView.contentSize.height, self.scrollView.bounds.size.height);
    
    CGFloat leftOffset = -contentOffset.x;
    CGFloat topOffset = -contentOffset.y;
    CGFloat rightOffset = contentOffset.x - (contentWith - self.scrollView.bounds.size.width);
    CGFloat bottomOffset = contentOffset.y - (contentHeight - self.scrollView.bounds.size.height);
    
    CGFloat headerTriggerOffset = [self __i__getHeaderTriggerOffset];
    CGFloat trailerTriggerOffset = [self __i__getTrailerTriggerOffset];
    
    if (!self.isHeaderRefreshing) {
        BOOL canStartHeaderRefreshing = isEndDragging;
        if (!canStartHeaderRefreshing
            && [self.headerPullingView respondsToSelector:@selector(shouldTriggerOnDraggingForPullRefreshElement:)]) {
            canStartHeaderRefreshing = [self.headerPullingView shouldTriggerOnDraggingForPullRefreshElement:self];
        }
        
        switch (self.pullOrientation) {
            case VDPullRefreshOrientationVertical: {
                if (canStartHeaderRefreshing
                    && topOffset >= headerTriggerOffset) {
                    [self __i__setIsHeaderRefreshing:self.isHeaderPullingEnabled];
                }
                break;
            }
            case VDPullRefreshOrientationHorizontal: {
                if (canStartHeaderRefreshing
                    && leftOffset >= headerTriggerOffset) {
                    [self __i__setIsHeaderRefreshing:self.isHeaderPullingEnabled];
                }
                break;
            }
        }
    }
    
    if (!self.isTrailerRefreshing) {
        BOOL canStartTrailerRefreshing = isEndDragging;
        if (!canStartTrailerRefreshing
            && [self.trailerPullingView respondsToSelector:@selector(shouldTriggerOnDraggingForPullRefreshElement:)]) {
            canStartTrailerRefreshing = [self.trailerPullingView shouldTriggerOnDraggingForPullRefreshElement:self];
        }
        
        switch (self.pullOrientation) {
            case VDPullRefreshOrientationVertical: {
                if (canStartTrailerRefreshing
                    && bottomOffset >= trailerTriggerOffset) {
                    [self __i__setIsTrailerRefreshing:self.isTrailerPullingEnabled];
                }
                break;
            }
            case VDPullRefreshOrientationHorizontal: {
                if (canStartTrailerRefreshing
                    && rightOffset >= trailerTriggerOffset) {
                    [self __i__setIsTrailerRefreshing:self.isTrailerPullingEnabled];
                }
                break;
            }
        }
    }
    
    [self __i__updateScrollViewLayout];
}

- (void)__i__updateScrollViewLayout {
    if (!self.scrollView) {
        return;
    }
    
    if (!self.headerPullingView && !self.trailerPullingView) {
        return;
    }
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGFloat contentWith = MAX(self.scrollView.contentSize.width, self.scrollView.bounds.size.width);
    CGFloat contentHeight = MAX(self.scrollView.contentSize.height, self.scrollView.bounds.size.height);
    
    CGFloat leftOffset = -contentOffset.x;
    CGFloat topOffset = -contentOffset.y;
    CGFloat rightOffset = (contentWith - self.scrollView.bounds.size.width);
    CGFloat bottomOffset = contentOffset.y - (contentHeight - self.scrollView.bounds.size.height);
    
    switch (self.pullOrientation) {
        case VDPullRefreshOrientationVertical: {
            if ([self.headerPullingView respondsToSelector:@selector(layoutTypeForPullRefreshElement:withEnabled:refreshing:pullingOffset:)]) {
                self.headerLayoutType = [self.headerPullingView layoutTypeForPullRefreshElement:self withEnabled:self.isHeaderPullingEnabled refreshing:self.isHeaderRefreshing pullingOffset:topOffset];
            }
            if ([self.trailerPullingView respondsToSelector:@selector(layoutTypeForPullRefreshElement:withEnabled:refreshing:pullingOffset:)]) {
                self.trailerLayoutType = [self.trailerPullingView layoutTypeForPullRefreshElement:self withEnabled:self.isTrailerPullingEnabled refreshing:self.isTrailerRefreshing pullingOffset:bottomOffset];
            }
            break;
        }
        case VDPullRefreshOrientationHorizontal: {
            if ([self.headerPullingView respondsToSelector:@selector(layoutTypeForPullRefreshElement:withEnabled:refreshing:pullingOffset:)]) {
                self.headerLayoutType = [self.headerPullingView layoutTypeForPullRefreshElement:self withEnabled:self.isHeaderPullingEnabled refreshing:self.isHeaderRefreshing pullingOffset:leftOffset];
            }
            if ([self.trailerPullingView respondsToSelector:@selector(layoutTypeForPullRefreshElement:withEnabled:refreshing:pullingOffset:)]) {
                self.trailerLayoutType = [self.trailerPullingView layoutTypeForPullRefreshElement:self withEnabled:self.isTrailerPullingEnabled refreshing:self.isTrailerRefreshing pullingOffset:rightOffset];
            }
            break;
        }
    }
    
    if (self.headerLayoutType == VDPullRefreshLayoutTypeHide) {
        [self.headerPullingView removeFromSuperview];
    }
    else {
        [self __i__addHeaderView];
    }
    
    if (self.trailerLayoutType == VDPullRefreshLayoutTypeHide) {
        [self.trailerPullingView removeFromSuperview];
    }
    else {
        [self __i__addTrailerView];
    }
    
    UIEdgeInsets willChangeOffsetInsets = UIEdgeInsetsZero;
    
    BOOL isHeaderInside = self.headerLayoutType == VDPullRefreshLayoutTypeShowAndLayoutInside;
    if (!isHeaderInside) {
        isHeaderInside = self.isHeaderPullingEnabled
                            && self.isHeaderRefreshing
                            && self.headerLayoutType == VDPullRefreshLayoutTypeShowAndLayoutInsideWhenRefreshing;
    }
    
    if (isHeaderInside) {
        switch (self.pullOrientation) {
            case VDPullRefreshOrientationVertical: {
                willChangeOffsetInsets.top = [self __i__getHeaderViewHeight];
                break;
            }
            case VDPullRefreshOrientationHorizontal: {
                willChangeOffsetInsets.left = [self __i__getHeaderViewHeight];
                break;
            }
        }
    }
    else {
        switch (self.pullOrientation) {
            case VDPullRefreshOrientationVertical: {
                willChangeOffsetInsets.top = 0.0f;
                break;
            }
            case VDPullRefreshOrientationHorizontal: {
                willChangeOffsetInsets.left = 0.0f;
                break;
            }
        }
    }
    
    BOOL isTrailerInside = self.trailerLayoutType == VDPullRefreshLayoutTypeShowAndLayoutInside;
    if (!isTrailerInside) {
        isTrailerInside = self.isTrailerPullingEnabled
                            && self.isTrailerRefreshing
                            && self.trailerLayoutType == VDPullRefreshLayoutTypeShowAndLayoutInsideWhenRefreshing;
    }
    
    if (isTrailerInside) {
        switch (self.pullOrientation) {
            case VDPullRefreshOrientationVertical: {
                willChangeOffsetInsets.bottom = [self __i__getTrailerViewHeight];
                break;
            }
            case VDPullRefreshOrientationHorizontal: {
                willChangeOffsetInsets.right = [self __i__getTrailerViewHeight];
                break;
            }
        }
    }
    else {
        switch (self.pullOrientation) {
            case VDPullRefreshOrientationVertical: {
                willChangeOffsetInsets.bottom = 0.0f;
                break;
            }
            case VDPullRefreshOrientationHorizontal: {
                willChangeOffsetInsets.right = 0.0f;
                break;
            }
        }
    }

    if (!UIEdgeInsetsEqualToEdgeInsets(self.currentOffsetEdgeInsets, willChangeOffsetInsets)) {
        UIEdgeInsets scrollViewInsets = self.scrollView.contentInset;
        scrollViewInsets.left += willChangeOffsetInsets.left - self.currentOffsetEdgeInsets.left;
        scrollViewInsets.top += willChangeOffsetInsets.top - self.currentOffsetEdgeInsets.top;
        scrollViewInsets.right += willChangeOffsetInsets.right - self.currentOffsetEdgeInsets.right;
        scrollViewInsets.bottom += willChangeOffsetInsets.bottom - self.currentOffsetEdgeInsets.bottom;
        self.currentOffsetEdgeInsets = willChangeOffsetInsets;
        
        // TODO: with animation, the content offset is not change continious
        // TODO: add end refreshing state
        if (self.scrollView.isDragging || !self.animatingPullbackEnable) {
            self.scrollView.contentInset = scrollViewInsets;
        }
        else {
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                             animations:^{
                                 self.scrollView.contentInset = scrollViewInsets;
                             }
                             completion:NULL];
        }
    }

}

@end

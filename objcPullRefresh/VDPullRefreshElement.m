//
//  VDPullRefreshElement.m
//  objcTemp
//
//  Created by Deng on 16/7/20.
//  Copyright © Deng. All rights reserved.
//

#import "VDPullRefreshElement.h"
#import <objcKeyPath/objcKeyPath.h>


@interface VDPullRefreshElement () <UIScrollViewDelegate>

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
            [self internalRemoveScrollView:_scrollView];
        }
        
        _scrollView = scrollView;
        
        if (_scrollView) {
            [self internalAddScrollView:_scrollView];
            [self internalAddHeaderView];
            [self internalAddTrailerView];
        }
    }
}

- (void)setHeaderPullingView:(UIView<VDPullRefreshPullingHeaderView> *)headerPullingView {
    if (_headerPullingView != headerPullingView) {
        [_headerPullingView removeFromSuperview];
        _headerPullingView = headerPullingView;
        [self internalAddHeaderView];
    }
}

- (void)setTrailerPullingView:(UIView<VDPullRefreshPullingTrailerView> *)trailerPullingView {
    if (_trailerPullingView != trailerPullingView) {
        [_trailerPullingView removeFromSuperview];
        _trailerPullingView = trailerPullingView;
        [self internalAddTrailerView];
    }
}

- (void)setPullOrientation:(VDPullRefreshOrientation)pullOrientation {
    if (_pullOrientation != pullOrientation) {
        _pullOrientation = pullOrientation;
        self.isHeaderRefreshing = NO;
        self.isTrailerRefreshing = NO;
        [self internalLayoutHeaderView];
        [self internalLayoutTrailerView];
        [self internalUpdateScrollViewLayout];
    }
}

- (void)setIsHeaderPullingEnabled:(BOOL)isHeaderPullingEnabled {
    if (_isHeaderPullingEnabled != isHeaderPullingEnabled) {
        _isHeaderPullingEnabled = isHeaderPullingEnabled;
        if (!_isHeaderPullingEnabled) {
            [self internalSetIsHeaderRefreshing:NO];
        }
        [self internalUpdateScrollViewLayout];
        
        if ([self.pullRefreshDelegate respondsToSelector:@selector(pullRefreshElement:headerPullingEnableStateChange:)]) {
            [self.pullRefreshDelegate pullRefreshElement:self headerPullingEnableStateChange:_isHeaderPullingEnabled];
        }
    }
}

- (void)setIsHeaderRefreshing:(BOOL)isHeaderRefreshing {
    [self internalSetIsHeaderRefreshing:isHeaderRefreshing];
    [self internalUpdateScrollViewLayout];
}

- (void)internalSetIsHeaderRefreshing:(BOOL)isHeaderRefreshing {
    if (isHeaderRefreshing && !self.isHeaderPullingEnabled) {
        return;
    }
    
    if (_isHeaderRefreshing != isHeaderRefreshing) {
        _isHeaderRefreshing = isHeaderRefreshing;
        
        if (_isHeaderRefreshing
            && self.headerRefreshActionBlock) {
            self.headerRefreshActionBlock();
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
            [self internalSetIsTrailerRefreshing:NO];
        }
        [self internalUpdateScrollViewLayout];
        
        if ([self.pullRefreshDelegate respondsToSelector:@selector(pullRefreshElement:trailerPullingEnableStateChange:)]) {
            [self.pullRefreshDelegate pullRefreshElement:self trailerPullingEnableStateChange:_isTrailerPullingEnabled];
        }
    }
}

- (void)setIsTrailerRefreshing:(BOOL)isTrailerRefreshing {
    [self internalSetIsTrailerRefreshing:isTrailerRefreshing];
    [self internalUpdateScrollViewLayout];
}

- (void)internalSetIsTrailerRefreshing:(BOOL)isTrailerRefreshing {
    if (isTrailerRefreshing && !self.isTrailerPullingEnabled) {
        return;
    }
    
    if (_isTrailerRefreshing != isTrailerRefreshing) {
        _isTrailerRefreshing = isTrailerRefreshing;
        if (_isTrailerRefreshing
            && self.trailerRefreshActionBlock) {
            self.trailerRefreshActionBlock();
        }
        
        if ([self.pullRefreshDelegate respondsToSelector:@selector(pullRefreshElement:trailerRefreshingStateChange:)]) {
            [self.pullRefreshDelegate pullRefreshElement:self trailerRefreshingStateChange:_isTrailerRefreshing];
        }
    }
}

#pragma mark Overrides
- (instancetype)init {
    self = [super init];
    
    [self internalInitVDPullRefreshElement];
    
    return self;
}

- (void)dealloc {
    [self internalRemoveScrollView:self.scrollView];
    self.scrollView = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [self internalLayoutHeaderView];
    [self internalLayoutTrailerView];
    
    if ([keyPath isEqualToString:VDKeyPath(self.scrollView, contentOffset)]
        || [keyPath isEqualToString:VDKeyPath(self.scrollView, contentSize)]) {
        BOOL isEndDragging = self.isScrollViewDragging && !self.scrollView.isDragging;
        self.isScrollViewDragging = self.scrollView.isDragging;
        
        [self internalUpdatRefreshingState:isEndDragging];
    }
}

#pragma mark Delegates

#pragma mark Private Method
- (void)internalInitVDPullRefreshElement {
    _headerLayoutType = VDPullRefreshLayoutTypeShowAndLayoutInsideWhenRefreshing;
    _trailerLayoutType = VDPullRefreshLayoutTypeShowAndLayoutInsideWhenRefreshing;
    _isScrollViewDragging = NO;
    _currentOffsetEdgeInsets = UIEdgeInsetsZero;
    _defaultHeaderPullingViewHeight = 60.0f;
    _defaultTrailerPullingViewHeight = 60.0f;
    _animatingPullbackEnable = YES;
}

- (void)internalAddScrollView:(UIScrollView *)scrollView {
    [scrollView addObserver:self forKeyPath:VDKeyPath(_scrollView, bounds) options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [scrollView addObserver:self forKeyPath:VDKeyPath(_scrollView, contentOffset) options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [scrollView addObserver:self forKeyPath:VDKeyPath(_scrollView, contentSize) options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

- (void)internalRemoveScrollView:(UIScrollView *)scrollView {
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

- (void)internalAddHeaderView {
    if (self.headerPullingView.superview == self.scrollView) {
        return;
    }
    if (self.scrollView && self.headerPullingView) {
        [self.headerPullingView removeFromSuperview];
        [self.scrollView addSubview:self.headerPullingView];
        [self internalLayoutHeaderView];
    }

    self.isHeaderPullingEnabled = self.headerPullingView != nil;
}

- (void)internalAddTrailerView {
    if (self.trailerPullingView.superview == self.scrollView) {
        return;
    }
    if (self.scrollView && self.trailerPullingView) {
        [self.trailerPullingView removeFromSuperview];
        [self.scrollView addSubview:self.trailerPullingView];
        [self internalLayoutTrailerView];
    }
    
    self.isTrailerPullingEnabled = self.trailerPullingView != nil;
}

- (CGFloat)internalGetHeaderViewHeight {
    if (!self.headerPullingView) {
        return 0.0f;
    }
    
    CGFloat height = self.defaultHeaderPullingViewHeight;
    if ([self.headerPullingView respondsToSelector:@selector(pullingViewHeightForPullRefreshElement:)]) {
        height = [self.headerPullingView pullingViewHeightForPullRefreshElement:self];
    }
    
    return height;
}

- (CGFloat)internalGetHeaderTriggerOffset {
    if (!self.headerPullingView) {
        return HUGE_VALF;
    }
    
    CGFloat offset = [self internalGetHeaderViewHeight];
    if ([self.headerPullingView respondsToSelector:@selector(triggerRefreshingOffsetForPullRefreshElement:)]) {
        offset = [self.headerPullingView triggerRefreshingOffsetForPullRefreshElement:self];
    }
    
    return offset;
}

- (CGFloat)internalGetTrailerViewHeight {
    if (!self.trailerPullingView) {
        return 0.0f;
    }
    
    CGFloat height = self.defaultTrailerPullingViewHeight;
    if ([self.trailerPullingView respondsToSelector:@selector(pullingViewHeightForPullRefreshElement:)]) {
        height = [self.trailerPullingView pullingViewHeightForPullRefreshElement:self];
    }
    
    return height;
}

- (CGFloat)internalGetTrailerTriggerOffset {
    if (!self.trailerPullingView) {
        return HUGE_VALF;
    }
    
    CGFloat offset = [self internalGetTrailerViewHeight];
    if ([self.trailerPullingView respondsToSelector:@selector(triggerRefreshingOffsetForPullRefreshElement:)]) {
        offset = [self.trailerPullingView triggerRefreshingOffsetForPullRefreshElement:self];
    }
    if ([self.trailerPullingView respondsToSelector:@selector(triggerRefreshingOffsetByScrollViewPageSizeMultiplierForPullRefreshElement:)]) {
        offset = -self.scrollView.bounds.size.height * [self.trailerPullingView triggerRefreshingOffsetByScrollViewPageSizeMultiplierForPullRefreshElement:self];
    }
    
    return offset;
}

- (void)internalLayoutHeaderView {
    if (self.headerPullingView) {
        CGFloat height = [self internalGetHeaderViewHeight];
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

- (void)internalLayoutTrailerView {
    if (self.trailerPullingView) {
        CGFloat height = [self internalGetTrailerViewHeight];
        
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

- (void)internalUpdatRefreshingState:(BOOL)isEndDragging {
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
    
    CGFloat headerTriggerOffset = [self internalGetHeaderTriggerOffset];
    CGFloat trailerTriggerOffset = [self internalGetTrailerTriggerOffset];
    
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
                    [self internalSetIsHeaderRefreshing:self.isHeaderPullingEnabled];
                }
                break;
            }
            case VDPullRefreshOrientationHorizontal: {
                if (canStartHeaderRefreshing
                    && leftOffset >= headerTriggerOffset) {
                    [self internalSetIsHeaderRefreshing:self.isHeaderPullingEnabled];
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
                    [self internalSetIsTrailerRefreshing:self.isTrailerPullingEnabled];
                }
                break;
            }
            case VDPullRefreshOrientationHorizontal: {
                if (canStartTrailerRefreshing
                    && rightOffset >= trailerTriggerOffset) {
                    [self internalSetIsTrailerRefreshing:self.isTrailerPullingEnabled];
                }
                break;
            }
        }
    }
    
    [self internalUpdateScrollViewLayout];
}

- (void)internalUpdateScrollViewLayout {
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
        [self internalAddHeaderView];
    }
    
    if (self.trailerLayoutType == VDPullRefreshLayoutTypeHide) {
        [self.trailerPullingView removeFromSuperview];
    }
    else {
        [self internalAddTrailerView];
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
                willChangeOffsetInsets.top = [self internalGetHeaderViewHeight];
                break;
            }
            case VDPullRefreshOrientationHorizontal: {
                willChangeOffsetInsets.left = [self internalGetHeaderViewHeight];
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
                willChangeOffsetInsets.bottom = [self internalGetTrailerViewHeight];
                break;
            }
            case VDPullRefreshOrientationHorizontal: {
                willChangeOffsetInsets.right = [self internalGetTrailerViewHeight];
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

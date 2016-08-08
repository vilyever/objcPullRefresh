//
//  VDDefaultPullingView.m
//  objcPullRefresh
//
//  Created by Deng on 16/7/21.
//  Copyright © Deng. All rights reserved.
//

#import "VDDefaultPullingView.h"


@interface VDDefaultPullingView ()

- (void)__i__initVDDefaultPullingView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *infoLabel;

@end


@implementation VDDefaultPullingView

#pragma mark Public Method
+ (VDDefaultPullingView *)pullingHeaderView {
    return [[self alloc] initWithTrailer:NO];
}

+ (VDDefaultPullingView *)pullingTrailerView {
    return [[self alloc] initWithTrailer:YES];
}

- (instancetype)initWithTrailer:(BOOL)isTrailer {
    self = [super init];
    
    _isTrailer = isTrailer;
    
    return self;
}

#pragma mark Properties
- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = NO;
        [_indicatorView stopAnimating];
    }
    
    return _indicatorView;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = [UIColor grayColor];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _infoLabel;
}

#pragma mark Overrides
- (instancetype)init {
    self = [super init];
    
    [self __i__initVDDefaultPullingView];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self __i__initVDDefaultPullingView];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [self __i__initVDDefaultPullingView];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)dealloc {
    
}

- (void)layoutSubviews {
    
    
    
    CGFloat height = MIN(self.bounds.size.width, self.bounds.size.height);
    self.indicatorView.bounds = CGRectMake(0.0f, 0.0f, height, height);
    self.indicatorView.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
    self.infoLabel.frame = self.bounds;
    
    [super layoutSubviews];
}


#pragma mark IBActions


#pragma mark Delegates
- (CGFloat)pullingViewHeightForPullRefreshElement:(VDPullRefreshElement *)element {
    return self.isTrailer ? 44.0f : 60.0f;
}

- (CGFloat)triggerRefreshingOffsetForPullRefreshElement:(VDPullRefreshElement *)element {
    return 60.0f;
}

- (CGFloat)triggerRefreshingOffsetByScrollViewPageSizeMultiplierForPullRefreshElement:(VDPullRefreshElement *)element {
    return 1.0f;
}

- (BOOL)shouldTriggerOnDraggingForPullRefreshElement:(VDPullRefreshElement *)element {
    return self.isTrailer;
}

- (VDPullRefreshLayoutType)layoutTypeForPullRefreshElement:(VDPullRefreshElement *)element withEnabled:(BOOL)enabled refreshing:(BOOL)isRefreshing pullingOffset:(CGFloat)pullingOffset {
    
    if (isRefreshing) {
        [self.indicatorView startAnimating];
    }
    else {
        [self.indicatorView stopAnimating];
    }
    
    if (!self.isTrailer) {
        self.infoLabel.hidden = YES;
        
        CGFloat percent = isRefreshing ? 1.0f : MIN(pullingOffset / [self triggerRefreshingOffsetForPullRefreshElement:element], 1.0f);
        self.indicatorView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(M_PI * 2.0f * percent), CGAffineTransformMakeScale(1.0f + percent, 1.0f + percent));
        
        if (enabled) {
            return VDPullRefreshLayoutTypeShowAndLayoutInsideWhenRefreshing;
        }
        else {
            return VDPullRefreshLayoutTypeHide;
        }
    }
    else {
        self.infoLabel.hidden = enabled;
        self.indicatorView.hidden = !enabled;
        
        self.infoLabel.text = @"END";
        
        if (enabled) {
            return VDPullRefreshLayoutTypeShowAndLayoutInsideWhenRefreshing;
        }
        else {
            return VDPullRefreshLayoutTypeShowAndLayoutOutside;
        }
    }
}

#pragma mark Private Method
- (void)__i__initVDDefaultPullingView {
    
    [self addSubview:self.indicatorView];
    [self addSubview:self.infoLabel];
}

@end

//
//  VDDefaultPullingView.h
//  objcTemp
//
//  Created by Deng on 16/7/21.
//  Copyright © Deng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VDPullRefreshElement.h"


@class VDDefaultPullingView;

@interface VDDefaultPullingView : UIView<VDPullRefreshPullingHeaderView, VDPullRefreshPullingTrailerView>

#pragma mark Public Method
+ (VDDefaultPullingView *)pullingHeaderView;
+ (VDDefaultPullingView *)pullingTrailerView;
- (instancetype)initWithTrailer:(BOOL)isTrailer;

#pragma mark Properties
@property (nonatomic, assign) BOOL isTrailer;

#pragma mark Private Method
- (void)internalInitVDDefaultPullingView;

@end

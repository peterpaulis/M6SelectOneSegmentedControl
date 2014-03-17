//
//  M6SelectOneSegmentedControl.h
//  M6SelectOneSegmentedControl
//
//  Created by Peter Paulis on 17.03.2013.
//  Copyright (c) 2013 min:60 s.r.o. - http://min60.com - Peter Paulis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DelegatedProgressAnimation.h"

@interface M6SelectOneSegmentedControl : NSSegmentedControl <DelegatedProgressAnimationDelegate>

@property (assign) CGFloat roundedCornerRadius;
@property (assign) CGFloat animationDuration;

- (void)setSelectedSegment:(NSInteger)newSegment animated:(BOOL)animated;

@end

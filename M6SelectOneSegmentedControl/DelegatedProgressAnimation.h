//
//  DelegatedProgressAnimation.h
//  M6SelectOneSegmentedControl
//
//  Created by Peter Paulis on 17/03/14.
//  Copyright (c) 2014 min:60 s.r.o. - http://min60.com - Peter Paulis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DelegatedProgressAnimation;

@protocol DelegatedProgressAnimationDelegate <NSObject>

- (void)delegatedProgressAnimation:(DelegatedProgressAnimation *)animation didProgress:(CGFloat)progress value:(CGFloat)value;

@end

@interface DelegatedProgressAnimation : NSAnimation

@property (weak) id<DelegatedProgressAnimationDelegate> progressDelegate;
@property (assign) CGFloat start;
@property (assign) CGFloat end;

@end

//
//  DelegatedProgressAnimation.m
//  M6SelectOneSegmentedControl
//
//  Created by Peter Paulis on 17/03/14.
//  Copyright (c) 2014 min:60 s.r.o. - http://min60.com - Peter Paulis. All rights reserved.
//

#import "DelegatedProgressAnimation.h"

@implementation DelegatedProgressAnimation

- (void)setCurrentProgress:(NSAnimationProgress)progress {
    
    [super setCurrentProgress:progress];
    
    CGFloat value = self.start + progress * (self.end - self.start);
    [self.progressDelegate delegatedProgressAnimation:self didProgress:progress value:value];
        
}

@end


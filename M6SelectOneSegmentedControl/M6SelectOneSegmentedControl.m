//
//  M6SelectOneSegmentedControl.m
//  M6SelectOneSegmentedControl
//
//  Created by Peter Paulis on 17.03.2013.
//  Copyright (c) 2013 min:60 s.r.o. - http://min60.com - Peter Paulis. All rights reserved.
//

#import "M6SelectOneSegmentedControl.h"

// Categories
#import "NSBezierPath+MCAdditions.h"
#import "NSShadow+MCAdditions.h"

@interface M6SelectOneSegmentedControl()

@property (nonatomic, assign) CGFloat knobXPosition;

@end

@implementation M6SelectOneSegmentedControl

////////////////////////////////////////////////////////////////////////
#pragma mark - init
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setDefaults];
        self.wantsLayer = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaults];
        self.wantsLayer = YES;
    }
    return self;
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self setFocusRingType:NSFocusRingTypeNone];
    [[self cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
    
    self.knobXPosition = [self xPositionForSegment:[self selectedSegment]];
    [self setNeedsDisplay];

}

- (void)drawRect:(NSRect)dirtyRect {
    
	NSRect rect = [self bounds];
	rect.size.height -= 1;
    
    [self drawBackgroud:rect];
    [self drawKnob:rect];
    [self drawForeground:dirtyRect];
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (NSInteger)segmentForXPosition:(CGFloat)x {
    return x / ([self bounds].size.width / [self segmentCount]) + 0.5f;
}

- (CGFloat)xPositionForSegment:(NSInteger)segment {
    if (segment == 0) {
        return 0.f;
    }
    return segment * ([self bounds].size.width / [self segmentCount]) + 0.5;
}

- (void)setDefaults {
    
    self.roundedCornerRadius = 3.f;
    self.animationDuration = 0.25;
    
}

- (void)mouseDown:(NSEvent *)event
{
    BOOL loop = YES;
    
    NSPoint clickLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat knobWidth = [self bounds].size.width / [self segmentCount];
    NSRect knobRect = NSMakeRect(self.knobXPosition, 0, knobWidth, [self bounds].size.height);
    
    if (NSPointInRect(clickLocation, [self bounds])) {
        
        NSPoint newDragLocation;
        NSPoint localLastDragLocation = clickLocation;
        
        while (loop) {
            
            NSEvent *localEvent;
            localEvent = [[self window] nextEventMatchingMask:(NSLeftMouseUpMask | NSLeftMouseDraggedMask)];
            
            switch ([localEvent type]) {
                    
                case NSLeftMouseDragged:
                    if (NSPointInRect(clickLocation, knobRect)) {
                        
                        newDragLocation = [self convertPoint:[localEvent locationInWindow] fromView:nil];
                        
                        self.knobXPosition += (newDragLocation.x - localLastDragLocation.x);
                        
                        localLastDragLocation = newDragLocation;
                        [self autoscroll:localEvent];
                    }             
                    break;
                case NSLeftMouseUp:
                    loop = NO;
                    
                    NSInteger newSegment = [self segmentForXPosition:self.knobXPosition];
                    if ([self isEnabledForSegment:newSegment]) {
                        [self setSelectedSegment:newSegment animated:YES];
                        //[[self window] invalidateCursorRectsForView:self];
                        //[self sendAction:[self action] to:[self target]];
                    } else {
                        
                        [self setKnobXPosition:[self xPositionForSegment:[self selectedSegment]] animated:YES];
                        
                    }
                    
                    break;
                default:
                    break;
            }
        }
    };
    return;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Setters / Getters
////////////////////////////////////////////////////////////////////////

- (void)setKnobXPosition:(CGFloat)knobXPosition {
    
    [self setKnobXPosition:knobXPosition animated:NO];
    
}

- (void)setKnobXPosition:(CGFloat)knobXPosition animated:(BOOL)animated {
    
    if (_knobXPosition == knobXPosition) {
        return;
    }
    
    if ((knobXPosition < 0.f) || (knobXPosition > [self xPositionForSegment:([self segmentCount] - 1)])) {
        return;
    }
    
    animated = self.animationDuration > 0.f ? animated : NO;
    
    if (animated) {
        
        DelegatedProgressAnimation * animation = [[DelegatedProgressAnimation alloc] initWithDuration:self.animationDuration animationCurve:NSAnimationEaseInOut];
        animation.start = self.knobXPosition;
        animation.end = knobXPosition;
        animation.progressDelegate = self;
        [animation setAnimationBlockingMode:NSAnimationBlocking];
        [animation startAnimation];
        
    } else {
        
        _knobXPosition = knobXPosition;
        
    }
    
    [self setNeedsDisplay];
    
}

- (void)setSelectedSegment:(NSInteger)newSegment {
    
    [self setSelectedSegment:newSegment animated:YES];
    
}

- (void)setSelectedSegment:(NSInteger)newSegment animated:(BOOL)animated {
    
    if ((newSegment < -1) || (newSegment >= [self segmentCount])) {
        return;
    }
    
    [self setKnobXPosition:[self xPositionForSegment:newSegment] animated:animated];
    
    [super setSelectedSegment:newSegment];
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Helpers
////////////////////////////////////////////////////////////////////////

- (NSImage *)image:(NSImage *)sourceImage tintedWithColor:(NSColor *)tint {
    NSImage *image = [sourceImage copy];
    if (tint) {
        [image lockFocus];
        [tint set];
        NSRect imageRect = {NSZeroPoint, [image size]};
        NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);
        [image unlockFocus];
    }
    return image;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Drawing code
////////////////////////////////////////////////////////////////////////

- (void)drawForeground:(NSRect)rect {

    // Adjust
    {
        NSColor *frameColor;
        
        if ([[self window] isKeyWindow]) {
            frameColor = [NSColor colorWithCalibratedWhite:.37 alpha:1.0] ;
        } else {
            frameColor = [NSColor colorWithCalibratedWhite:.68 alpha:1.0] ;
        }
        
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:self.roundedCornerRadius yRadius:self.roundedCornerRadius];
        [frameColor setStroke];
        [path strokeInside];
    }

}

- (void)drawKnob:(NSRect)rect {
    
    CGFloat width = rect.size.width / [self segmentCount];
    CGFloat height = rect.size.height + 1.f;
    NSRect knobRect = NSMakeRect(self.knobXPosition, rect.origin.y, width, height);
    
    int newSegment = (int)round(self.knobXPosition / width);
    if ((newSegment < 0) || (newSegment >= [self segmentCount])) {
        // no index selected, don't draw
        return;
    }
    
    // Adjust
    {
        CGFloat radius = 3;
        NSGradient *gradient;
        NSColor *frameColor;
        
        if ([[self window] isKeyWindow]) {
            gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:.68 alpha:1.0]
                                                     endingColor:[NSColor colorWithCalibratedWhite:.91 alpha:1.0]];
            frameColor = [NSColor colorWithCalibratedWhite:.37 alpha:1.0] ;
        } else {
            gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:.76 alpha:1.0]
                                                     endingColor:[NSColor colorWithCalibratedWhite:.90 alpha:1.0]];
            frameColor = [NSColor colorWithCalibratedWhite:.68 alpha:1.0] ;
        }
        
        NSBezierPath *clipPath = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:self.roundedCornerRadius yRadius:self.roundedCornerRadius];
        [clipPath setClip];
        
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:knobRect
                                                             xRadius:radius
                                                             yRadius:radius];
        [gradient drawInBezierPath:path angle:-90];
        
        [frameColor setStroke];
        [path strokeInsideWithinRect:NSZeroRect clipPath:clipPath];
        
    }
    
    [self drawImageForSegment:newSegment withFrame:knobRect inKnob:YES];
}

- (void)drawBackgroud:(NSRect)rect {
    
    // Draw control background
    {
        NSGradient *gradient;
        
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:self.roundedCornerRadius yRadius:self.roundedCornerRadius];
        
        NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
        
        if ([[self window] isKeyWindow]) {
            gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:.75 alpha:1.0]
                                                     endingColor:[NSColor colorWithCalibratedWhite:.6 alpha:1.0]];
            
        } else {
            gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:.8 alpha:1.0]
                                                     endingColor:[NSColor colorWithCalibratedWhite:.77 alpha:1.0]];
        }
        
        [ctx saveGraphicsState];
        [path setClip];
        NSShadow *dropShadow = [[NSShadow alloc] init];
        [dropShadow setShadowOffset:NSMakeSize(0, -4.0)];
        [dropShadow setShadowBlurRadius:1.0];
        [dropShadow setShadowColor:[NSColor colorWithCalibratedWhite:.863 alpha:.75]];
        [dropShadow set];
        [path fill];
        [ctx restoreGraphicsState];
        
        [gradient drawInBezierPath:path angle:-90];
        
        [[NSColor clearColor] setStroke];
        [path strokeInside];
        
    }
    
    // Draw segment background individualy
    {
        CGFloat segmentWidth = rect.size.width / [self segmentCount];
        CGFloat segmentHeight = rect.size.height;
        NSRect segmentRect = NSMakeRect(0, 0, segmentWidth, segmentHeight);
        for (NSInteger segment = 0; segment < [self segmentCount]; ++segment) {
            segmentRect.origin.x = segment * segmentWidth;
            [self drawBackgroundForSegment:segment withFrame:segmentRect];
        }
    }
    
}

- (void)drawBackgroundForSegment:(NSInteger)segment withFrame:(NSRect)frame {
    
    // Adjust
    {
        
    }
    
    [self drawImageForSegment:segment withFrame:frame inKnob:NO];
}

- (void)drawImageForSegment:(NSInteger)segment withFrame:(NSRect)frame inKnob:(BOOL)inKnob {
    
    float imageFraction = 1.f;
    NSImage *image = [self imageForSegment:segment];
    
    // Adjust
    {
        if (![self isEnabledForSegment:segment]) {
            
            imageFraction = .1;
            image = [self image:image tintedWithColor:[NSColor redColor]];
            
        } else if ([self isSelectedForSegment:segment]) {
            
            imageFraction = 1.f;
            if (inKnob) {
                image = [self image:image tintedWithColor:[NSColor blueColor]];
            }
            
        } else {
            
            
        }
        
        if (![[self window] isKeyWindow]) {
            imageFraction = .25;
        }
    }
    
    // Draw in center of frame
    {
        CGSize imageSize = [image size];
        
        CGRect rect;
        rect.origin.x = frame.origin.x + (frame.size.width - imageSize.width) / 2.0;
        rect.origin.y = frame.origin.y + (frame.size.height - imageSize.height) / 2.0;
        rect.size.width = imageSize.width;
        rect.size.height = imageSize.height;
        
        [image drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:imageFraction respectFlipped:YES hints:@{NSImageHintInterpolation : @(NSImageInterpolationHigh)}];
    }
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - DelegatedProgressAnimationDelegate
////////////////////////////////////////////////////////////////////////

- (void)delegatedProgressAnimation:(DelegatedProgressAnimation *)animation didProgress:(CGFloat)progress value:(CGFloat)value {
 
    self.knobXPosition = value;;
    [self display];
    
}

@end

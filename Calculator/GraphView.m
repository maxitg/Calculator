//
//  GraphView.m
//  Calculator
//
//  Created by Maxim Piskunov on 13.07.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize origin = _origin;
@synthesize scale = _scale;

#define DEFAULT_SCALE 1.;

- (CGFloat)scale
{
    if (!_scale) {
        return DEFAULT_SCALE;
    } else {
        return _scale;
    }
}

- (void)setScale:(CGFloat)scale
{
    if (scale != _scale) {
        _scale = scale;
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        [userDefaults setFloat:scale forKey:@"scale"];
        [userDefaults synchronize];
        [self setNeedsDisplay];
    }
}

- (void)setOrigin:(CGPoint)origin
{
    if (origin.x != _origin.x || origin.y != _origin.y) {
        _origin = origin;
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
        [userDefaults setFloat:origin.x forKey:@"origin.x"];
        [userDefaults setFloat:origin.y forKey:@"origin.y"];
        [userDefaults synchronize];
        [self setNeedsDisplay];
    }
}

- (void)pinch:(UIPinchGestureRecognizer*)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale;
        gesture.scale = 1.;
    }
}

- (void)pan:(UIPanGestureRecognizer*)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint newOrigin;
        newOrigin.x = self.origin.x + [gesture translationInView:self].x/(self.bounds.size.width/2)/self.scale;
        newOrigin.y = self.origin.y - [gesture translationInView:self].y/(self.bounds.size.width/2)/self.scale;
        self.origin = newOrigin;
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)tripleTap:(UITapGestureRecognizer*)gesture
{
    CGPoint newOrigin;
    newOrigin.x = -([gesture locationInView:self].x - self.bounds.size.width/2.)/(self.bounds.size.width/2.)/self.scale + self.origin.x;
    newOrigin.y = +([gesture locationInView:self].y - self.bounds.size.height/2.)/(self.bounds.size.width/2.)/self.scale + self.origin.y;
    self.origin = newOrigin;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [AxesDrawer drawAxesInRect:rect originAtPoint:CGPointMake((0. + self.origin.x)*self.scale*(self.bounds.size.width/2.) + self.bounds.size.width/2., -(0. + self.origin.y)*self.scale*(self.bounds.size.width/2.) + self.bounds.size.height/2.) scale:self.bounds.size.width/2.*self.scale];
    
    for (CGFloat currentPointX = -1.; currentPointX < self.bounds.size.width + 1.; currentPointX += 1./self.contentScaleFactor) {
        float x = (currentPointX - self.bounds.size.width/2.)/(self.bounds.size.width/2.)/self.scale - self.origin.x;
        float y = [self.dataSource functionValueForX:x];
        CGFloat currentPointY = -(y + self.origin.y)*self.scale*(self.bounds.size.width/2.) + self.bounds.size.height/2.;
        
            //  Drawing with point sized rects
        
        CGContextAddRect(context, CGRectMake(currentPointX, currentPointY, 1./self.contentScaleFactor, 1./self.contentScaleFactor));
    }
    CGContextStrokePath(context);
}

@end

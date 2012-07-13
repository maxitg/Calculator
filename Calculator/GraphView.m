//
//  GraphView.m
//  Calculator
//
//  Created by Maxim Piskunov on 13.07.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"

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
        [self setNeedsDisplay];
    }
}

- (void)setOrigin:(CGPoint)origin
{
    if (origin.x != _origin.x || origin.y != _origin.y) {
        _origin = origin;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextMoveToPoint(context, -1., 0.);
    
    for (CGFloat currentPointX = -1.; currentPointX < self.bounds.size.width + 1.; currentPointX += 1./self.contentScaleFactor) {
        float x = (currentPointX - self.bounds.size.width/2.)/(self.bounds.size.width/2.)*self.scale - self.origin.x;
        float y = [self.dataSource functionValueForX:x];
        CGFloat currentPointY = -(y + self.origin.y)/self.scale*(self.bounds.size.width/2.) + self.bounds.size.height/2.;
//        CGContextAddLineToPoint(context, currentPointX, currentPointY);
        CGContextAddRect(context, CGRectMake(currentPointX, currentPointY, 1./self.contentScaleFactor, 1./self.contentScaleFactor));
    }
    CGContextStrokePath(context);
}

@end

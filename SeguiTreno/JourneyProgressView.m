//
//  TimeLineViewControl.m
//  Klubok
//
//  Inspired by Roma on 8/25/14.
//  Copyright (c) 2014 908 Inc. All rights reserved.
//


#import "JourneyProgressView.h"

#import <QuartzCore/QuartzCore.h>


const float LINE_WIDTH = 2.0;
const float CIRCLE_RADIUS = 6.0;


@implementation JourneyProgressView


- (id)initWithRow:(int)stop andMax:(int) max andCurrentStatus:(int) status andFrame:(CGRect)frame {
    
    self = [super initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    if (self) [self drawTimelineWith:stop currentStatus:status max:max];
    
    return self;
}



- (void)drawTimelineWith:(int)i currentStatus:(int)currentStatus max:(int)max {
    
    

    UIColor *strokeColor = i < currentStatus ? GREEN : [UIColor lightGrayColor];;
    CGPoint toPoint;
    CGPoint fromPoint;
    
    if(i==0) {              //iniziale
        
        // disegno cerchio
        CAShapeLayer *grayStaticCircleLayer = [self getLayerWithCircle:[self circleWithCenterY:self.frame.size.height/2] andStrokeColor:strokeColor];
        [self.layer addSublayer:grayStaticCircleLayer];

        // disegno linea sotto
        fromPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + CIRCLE_RADIUS);
        toPoint = CGPointMake(fromPoint.x, self.frame.size.height);
        CAShapeLayer *grayStaticLineLayer2 = [self getLayerWithLine:[self getLineWithStartPoint:fromPoint endPoint:toPoint] andStrokeColor:strokeColor];
        [self.layer addSublayer:grayStaticLineLayer2];
        
    } else if(i==max) {     //finale
        
        // disegno cerchio
        CAShapeLayer *grayStaticCircleLayer = [self getLayerWithCircle:[self circleWithCenterY:self.frame.size.height/2] andStrokeColor:strokeColor];
        [self.layer addSublayer:grayStaticCircleLayer];
        
        // disegno linea sopra
        fromPoint = CGPointMake(self.frame.size.width/2, 0);
        toPoint = CGPointMake(fromPoint.x, self.frame.size.height/2 - CIRCLE_RADIUS );
        CAShapeLayer *grayStaticLineLayer = [self getLayerWithLine:[self getLineWithStartPoint:fromPoint endPoint:toPoint] andStrokeColor:strokeColor];
        [self.layer addSublayer:grayStaticLineLayer];
        
        
    } else {                //intermedio

        // disegno cerchio
        CAShapeLayer *grayStaticCircleLayer = [self getLayerWithCircle:[self circleWithCenterY:self.frame.size.height/2] andStrokeColor:strokeColor];
        [self.layer addSublayer:grayStaticCircleLayer];

        // disegno linea sopra
        fromPoint = CGPointMake(self.frame.size.width/2, 0);
        toPoint = CGPointMake(fromPoint.x, self.frame.size.height/2 - CIRCLE_RADIUS );
        CAShapeLayer *grayStaticLineLayer = [self getLayerWithLine:[self getLineWithStartPoint:fromPoint endPoint:toPoint] andStrokeColor:strokeColor];
        [self.layer addSublayer:grayStaticLineLayer];
        
        // disegno linea sotto
        fromPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + CIRCLE_RADIUS);
        toPoint = CGPointMake(fromPoint.x, self.frame.size.height);
        CAShapeLayer *grayStaticLineLayer2 = [self getLayerWithLine:[self getLineWithStartPoint:fromPoint endPoint:toPoint] andStrokeColor:strokeColor];
        [self.layer addSublayer:grayStaticLineLayer2];
        
    }
    
 
}

- (CAShapeLayer *)getLayerWithLine:(UIBezierPath *)line andStrokeColor:(UIColor *)strokeColor {
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = line.CGPath;
    lineLayer.strokeColor = strokeColor.CGColor;
    lineLayer.fillColor = nil;
    lineLayer.lineWidth = LINE_WIDTH;
    
    return lineLayer;
}

- (UIBezierPath *)getLineWithStartPoint:(CGPoint)start endPoint:(CGPoint)end {
    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:start];
    [line addLineToPoint:end];
    
    return line;
}

- (CAShapeLayer *)getLayerWithCircle:(UIBezierPath *)circle andStrokeColor:(UIColor *)strokeColor {
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    
    circleLayer.path = circle.CGPath;
    
    circleLayer.strokeColor = strokeColor.CGColor;
    circleLayer.fillColor = nil;
    circleLayer.lineWidth = LINE_WIDTH;
    circleLayer.lineJoin = kCALineJoinBevel;
    
    return circleLayer;
}

- (UIBezierPath*) circleWithCenterY:(CGFloat)centerY {
    
    UIBezierPath *circle = [UIBezierPath bezierPath];
    [circle addArcWithCenter:CGPointMake(self.frame.size.width/2, centerY)
                      radius:CIRCLE_RADIUS
                  startAngle:0
                    endAngle:M_PI*2
                   clockwise:YES];
    
    return circle;
    
}

@end

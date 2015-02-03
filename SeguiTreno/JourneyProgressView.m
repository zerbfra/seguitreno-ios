//
//  JourneyProgressView
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 14/11/14.
//  Copyright (c) 2014 Francesco. All rights reserved.
//  Inspired by Roma on 8/25/14.
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


// i specifica se si è iniziale, finale o intermedio (finale i==max)
- (void)drawTimelineWith:(int)i currentStatus:(int)currentStatus max:(int)max {
    
    
    // il colore cambia in verde se la fermata è stata raggiunta
    UIColor *strokeColor = 1 ==  currentStatus ? GREEN : [UIColor lightGrayColor];
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

#pragma mark Gestore elementi grafici

// specifica il layer della linea (colore, spessore...)
- (CAShapeLayer *)getLayerWithLine:(UIBezierPath *)line andStrokeColor:(UIColor *)strokeColor {
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = line.CGPath;
    lineLayer.strokeColor = strokeColor.CGColor;
    lineLayer.fillColor = nil;
    lineLayer.lineWidth = LINE_WIDTH;
    
    return lineLayer;
}
// specifica il contorno e i parametri geometrici della linea
- (UIBezierPath *)getLineWithStartPoint:(CGPoint)start endPoint:(CGPoint)end {
    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:start];
    [line addLineToPoint:end];
    
    return line;
}
// specifica il layer del cerchio (colore, spessore...)
- (CAShapeLayer *)getLayerWithCircle:(UIBezierPath *)circle andStrokeColor:(UIColor *)strokeColor {
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    
    circleLayer.path = circle.CGPath;
    
    circleLayer.strokeColor = strokeColor.CGColor;
    circleLayer.fillColor = nil;
    circleLayer.lineWidth = LINE_WIDTH;
    circleLayer.lineJoin = kCALineJoinBevel;
    
    return circleLayer;
}
// specifica il contorno e i parametri geometrici del cerchio
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

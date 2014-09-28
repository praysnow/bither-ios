//
//  AudioVisualizerView.m
//  bither-ios
//
//  Created by noname on 14-9-28.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import "AudioVisualizerView.h"
@import QuartzCore;

#define kHorizontalStraightLineLength (20)
#define kMinAmptitude (0.1f)
#define kWaveCount (1)
#define kWaveDuration (0.5)
#define kSubLineCount (5)


@interface AudioVisualizerView(){
    float amptitude;
    CADisplayLink *displayLink;
    CAShapeLayer *mainLine;
    NSMutableArray *subLines;
    NSTimeInterval beginTime;
}
@end

@implementation AudioVisualizerView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self firstConfigure];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self firstConfigure];
    }
    return self;
}

-(void)firstConfigure{
    amptitude = kMinAmptitude;
    mainLine = [CAShapeLayer layer];
    mainLine.lineWidth = 2;
    mainLine.strokeColor = [UIColor whiteColor].CGColor;
    mainLine.fillColor = nil;
    mainLine.lineCap = @"round";
    mainLine.lineJoin = @"round";
    subLines = [[NSMutableArray alloc]init];
    for(int i = 0; i < kSubLineCount; i++){
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.lineWidth = 0.5f;
        layer.strokeColor = [UIColor colorWithWhite:1 alpha:0.4].CGColor;
        layer.fillColor = nil;
        layer.lineCap = @"round";
        layer.lineJoin = @"round";
        [subLines addObject:layer];
    }
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplay:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)handleDisplay:(CADisplayLink*)link{
    NSTimeInterval currentTime = displayLink.timestamp + displayLink.duration * displayLink.frameInterval;
    if(beginTime <= 0 || currentTime - beginTime > kWaveDuration){
        beginTime = currentTime;
    }
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;

    CGFloat xOffset = (width - kHorizontalStraightLineLength * 2) / kWaveCount / kWaveDuration * (currentTime - beginTime);
    UIBezierPath *mainPath = [UIBezierPath bezierPath];
    NSMutableArray* subPaths = [[NSMutableArray alloc]init];
    for(int i = 0; i < subLines.count; i++){
        [subPaths addObject:[UIBezierPath bezierPath]];
    }
    
    [mainPath moveToPoint:CGPointMake(0, height / 2)];
    CGFloat controlY = [self yForX:kHorizontalStraightLineLength * 3 offset:xOffset];
    [mainPath addQuadCurveToPoint:CGPointMake(kHorizontalStraightLineLength * 2, (height / 2 + controlY) / 2) controlPoint:CGPointMake(kHorizontalStraightLineLength, height / 2)];
    [mainPath addQuadCurveToPoint:CGPointMake(kHorizontalStraightLineLength * 4, [self yForX:kHorizontalStraightLineLength * 4 offset:xOffset]) controlPoint:CGPointMake(kHorizontalStraightLineLength * 3, controlY)];
    
    for(int i = 0; i < subPaths.count; i++){
        CGFloat rate = (i + 1.0f) / (CGFloat) (subPaths.count + 1);
        UIBezierPath *path = subPaths[i];
        [path moveToPoint:CGPointMake(0, height / 2)];
        
        controlY = [self yForX:kHorizontalStraightLineLength * 3 offset:xOffset] * rate;
        
        [path addQuadCurveToPoint:CGPointMake(kHorizontalStraightLineLength * 2, (height / 2 + controlY) / 2) controlPoint:CGPointMake(kHorizontalStraightLineLength, height / 2)];
        [path addQuadCurveToPoint:CGPointMake(kHorizontalStraightLineLength * 4, [self yForX:kHorizontalStraightLineLength * 4 offset:xOffset] * rate) controlPoint:CGPointMake(kHorizontalStraightLineLength * 3, controlY)];
    }
    
    for (float x = kHorizontalStraightLineLength * 4;
         x < width - kHorizontalStraightLineLength * 4;
         x+=0.5f) {
        
    }
}

-(CGFloat)yForX:(CGFloat)x offset:(CGFloat)xOffset{
    return (amptitude * (self.frame.size.height - 2 * mainLine.lineWidth) / 2.0f * sin(2 * M_PI * ((x - xOffset) / (self.frame.size.width - kHorizontalStraightLineLength * 2)) * kWaveCount) + self.frame.size.height / 2);
}

-(void)showConnectionData:(AVCaptureConnection *)connection{
    if(connection.audioChannels.count > 0){
        AVCaptureAudioChannel *channel = connection.audioChannels[0];
        double PeakPowerForChannel = pow(10, (0.05 * channel.peakHoldLevel));
        double averagePowerForChannel = pow(10, (0.05 * channel.averagePowerLevel));
        amptitude = 0.8 * PeakPowerForChannel + (1.0 - 0.8) * averagePowerForChannel;
    }else{
        amptitude = kMinAmptitude;
    }
    amptitude = MIN(MAX(amptitude, kMinAmptitude), 1);
}

-(void)dealloc{
    [displayLink invalidate];
    displayLink = nil;
}

@end

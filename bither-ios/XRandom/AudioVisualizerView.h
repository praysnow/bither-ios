//
//  AudioVisualizerView.h
//  bither-ios
//
//  Created by noname on 14-9-28.
//  Copyright (c) 2014年 noname. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@interface AudioVisualizerView : UIView
-(void)showConnectionData:(AVCaptureConnection *)connection;
@end

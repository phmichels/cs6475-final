//
//  PreviewView.h
//  FaceCam
//
//  Created by Paulo Michels on 4/24/16.
//  Copyright © 2016 Paulo Michels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PreviewView : UIView

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

- (id)initWithFrame:(CGRect)frame andSession:(AVCaptureSession *)session;

@end

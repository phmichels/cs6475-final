//
//  PreviewView.m
//  FaceCam
//
//  Created by Paulo Michels on 4/24/16.
//  Copyright © 2016 Paulo Michels. All rights reserved.
//

#import "PreviewView.h"

@implementation PreviewView

- (id)initWithFrame:(CGRect)frame andSession:(AVCaptureSession *)session {
    if (self = [super initWithFrame:frame]) {
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.previewLayer.frame = frame;
        
        [self.layer addSublayer:self.previewLayer];
    }

    return self;
}

@end

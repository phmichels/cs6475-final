//
//  ViewController.m
//  FaceCam
//
//  Created by Paulo Michels on 4/24/16.
//  Copyright © 2016 Paulo Michels. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PreviewView.h"
#import "ViewController.h"


@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) PreviewView *previewView;
@property (nonatomic, strong) CIDetector *faceDetector;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Video capturing
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *frontVideoCaptureDevice = nil;
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            frontVideoCaptureDevice = device;
        }
    }

    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:frontVideoCaptureDevice error:nil];
    [captureSession addInput:videoInput];
    
    // Video frame capturing
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [captureSession addOutput:videoOutput];
    //videoOutput.videoSettings = @{ kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] };

    dispatch_queue_t queue = dispatch_queue_create("frameProcessingQueue", NULL);
    [videoOutput setSampleBufferDelegate:self queue:queue];
    
    // Video preview
    self.previewView = [[PreviewView alloc] initWithFrame:self.view.frame andSession:captureSession];
    self.previewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.previewView];
    
    [captureSession startRunning];
    
    // Face detector
    NSDictionary *detectorOptions = @{CIDetectorAccuracy: CIDetectorAccuracyHigh};
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CVImageBufferRef cvImage = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:cvImage];
    
    CGFloat scale =  self.previewView.frame.size.height / ciImage.extent.size.width;
    
    NSArray *faces = [self.faceDetector featuresInImage:ciImage options:@{ CIDetectorImageOrientation: [NSNumber numberWithInt:6] }];

    if ([faces count] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.previewView.overlayView removeFromSuperview];
            self.previewView.overlayView = nil;
        });
        
        return;
    }
   
    for (CIFaceFeature *face in faces) {
        // Face Rectangle
        CGRect faceRect = CGRectMake(face.bounds.origin.y, face.bounds.origin.x, face.bounds.size.width, face.bounds.size.height);

        faceRect.size.width *= scale;
        faceRect.size.height *= scale;
        faceRect.origin.x *= scale;
        faceRect.origin.y *= scale;
        
        // Compensate for mirroring
        faceRect = CGRectOffset(faceRect, self.previewView.frame.size.width - faceRect.size.width - (faceRect.origin.x * 2), 0);
        
        
        // Eye Rectangle
        CGRect eyeRect = CGRectMake(face.bounds.origin.y, face.bounds.origin.x, face.bounds.size.width, face.bounds.size.height * .15);
    
        eyeRect.size.width *= scale;
        eyeRect.size.height *= scale;
        eyeRect.origin.x *= scale;
        eyeRect.origin.y *= scale;
        
        // Compensate for mirroring
        eyeRect = CGRectOffset(eyeRect, self.previewView.frame.size.width - eyeRect.size.width - (eyeRect.origin.x * 2), 0);
        eyeRect.origin.y = (face.leftEyePosition.x * scale) - (eyeRect.size.height / 2);
        
        
        // Update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.previewView.overlayView) {
                UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sunglass"]];
                imgView.contentMode = UIViewContentModeScaleAspectFill;
                
                self.previewView.overlayView = imgView;
                [self.previewView addSubview:imgView];
            }
            
            self.previewView.overlayView.frame = eyeRect;
        });
    }
        
}

@end

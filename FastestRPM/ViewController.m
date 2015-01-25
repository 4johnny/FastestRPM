//
//  ViewController.m
//  FastestRPM
//
//  Created by Johnny on 2015-01-24.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import "ViewController.h"


#
# pragma mark - Constants
#

#define MIN_DEGREES		-135.0
#define MAX_DEGREES		135.0
#define RANGE_DEGREES	(MAX_DEGREES - MIN_DEGREES)

#define MIN_SPEED	0.0		// Points per second
#define MAX_SPEED	100.0	// Points per second


#
# pragma mark - Macros
#

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)


#
# pragma mark - Interface
#

@interface ViewController ()

# pragma mark Properties

@property (nonatomic, readonly) CGAffineTransform minRotationTransform;
@property (nonatomic) CGPoint prevTranslation;

@end


#
# pragma mark - Implementation
#

@implementation ViewController


# pragma mark UIViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	// Initialize needle view to point to minimum mark on dial
	_minRotationTransform = CGAffineTransformMakeRotation(RADIANS(MIN_DEGREES));
	self.needleView.transform = self.minRotationTransform;
}


# pragma mark UIPanGestureRecognizer


- (IBAction)panGestureAction:(UIPanGestureRecognizer *)sender {
	
	CGPoint translation = [sender translationInView:self.view];
	
	switch (self.panGesture.state) {
			
		case UIGestureRecognizerStateChanged:
			MDLog(@"Translation Changed: (x:%f,y:%f)", translation.x, translation.y);
			[self moveNeedleWithTranslation:&translation];
			break;

		case UIGestureRecognizerStateEnded:
			MDLog(@"Translation Ended: (x:%f,y:%f)", translation.x, translation.y);
			[self moveNeedleWithTranslation:&translation];
			break;

		case UIGestureRecognizerStateBegan:
			MDLog(@"Translation Began: (x:%f,y:%f)", translation.x, translation.y);
			self.prevTranslation = translation;
			break;
			
		default:
			MDLog(@"Translation Unexpected: (x:%f,y:%f)", translation.x, translation.y);
			break;
	}
}


# pragma mark Helpers


- (void)moveNeedleWithTranslation:(CGPoint*) translation {
	
}


@end

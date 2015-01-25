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

#define LIMIT_VELOCITY	5000.0 // Points per second


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
@property (nonatomic) CGFloat maxVelocity;

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
	
	switch (self.panGesture.state) {
			
		case UIGestureRecognizerStateChanged:
			[self moveNeedleWithVelocity:[sender velocityInView:self.view]];
			break;
			
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateFailed:
			self.needleView.transform = self.minRotationTransform;
			break;
			
		case UIGestureRecognizerStateBegan:
			// Expected.  Do nothing.
			break;
			
		default:
			MDLog(@"Unexpected state: %d", (int)self.panGesture.state);
			break;
	}
}


# pragma mark Helpers


- (void)moveNeedleWithVelocity:(CGPoint)velocity {

	// Calculate velocity of pan motion
	CGFloat combinedVelocity = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2));
	self.maxVelocity = MAX(self.maxVelocity, combinedVelocity);
	
	// Calculate percentage of current velocity to velocity limit
	CGFloat velocityPercentage = combinedVelocity / LIMIT_VELOCITY;
	
	// Calculate proportion of RPM needle degree range
	CGFloat degrees = (MAX_DEGREES - MIN_DEGREES) * velocityPercentage;
	
	// Move needle in degree range proportionate to velocity
	self.needleView.transform = CGAffineTransformRotate(self.minRotationTransform, RADIANS(degrees));

	MDLog(@"Velocity: x:%.2f, y:%.2f, curr:%.2f, max:%.2f", velocity.x, velocity.y, combinedVelocity, self.maxVelocity);
}


@end

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

#define LIMIT_VELOCITY			7500.0 // Points per second
#define LIMIT_VELOCITY_DELTA	10.0 // Points per second

#define RESET_DELAY		0.1 // Seconds
#define VELOCITY_DELAY	0.1 // Seconds


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
@property (nonatomic) CGFloat currVelocity;
@property (nonatomic) NSTimer* resetTimer;
@property (nonatomic) NSTimer* velocityTimer;

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
	[self moveNeedleToMin];
	
	self.currVelocity = 0;
	self.resetTimer = nil;
	self.velocityTimer = nil;
}


# pragma mark UIPanGestureRecognizer


- (IBAction)panGestureAction:(UIPanGestureRecognizer *)sender {
	
	switch (self.panGesture.state) {
			
		case UIGestureRecognizerStateChanged: {
			
			// Get velocity from dimension components
			CGPoint componentVelocity = [sender velocityInView:self.view];
			CGFloat velocity = sqrt(pow(componentVelocity.x, 2) + pow(componentVelocity.y, 2));
			
			// Ignore velocity changes that are too small
			CGFloat velocityDelta = abs(velocity - self.currVelocity);
			if (velocityDelta < LIMIT_VELOCITY_DELTA) {
				//MDLog(@"Ignoring velocity delta: %.2f", velocityDelta);
				break;
			}
			
			// Since we have gestures, invalidate any timers
			if (self.resetTimer) {
				[self.resetTimer invalidate];
				self.resetTimer = nil;
				// MDLog(@"Invalidating reset timer");
			}
			if (self.velocityTimer) {
				[self.velocityTimer invalidate];
				self.velocityTimer = nil;
				// MDLog(@"Invalidating velocity timer");
			}
			
			// If velocity increased, render immediately; o/w render on delay
			if (velocity > self.currVelocity) {
			
				MDLog(@"Rendering velocity immediately");
				
				[self moveNeedleWithVelocity:velocity];
				
			} else {
			
				MDLog(@"Scheduling velocity timer");
				
				self.velocityTimer =
				[NSTimer scheduledTimerWithTimeInterval:VELOCITY_DELAY
												 target:self
											   selector:@selector(moveNeedleWithTimer:)
											   userInfo:[NSNumber numberWithFloat:velocity]
												repeats:NO];
			}
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateFailed:
			
			if (!self.resetTimer) {
				self.resetTimer =
				[NSTimer scheduledTimerWithTimeInterval:RESET_DELAY
												 target:self
											   selector:@selector(resetToMinWithTimer:)
											   userInfo:nil
												repeats:NO];
				MDLog(@"Scheduling reset timer");
			}
			break;
			
		case UIGestureRecognizerStateBegan:
			// Expected - do nothing
			break;
			
		default:
			MDLog(@"Unexpected pan gesture state: %d", (int)self.panGesture.state);
			break;
	}
}


# pragma mark Helpers


- (void)resetToMinWithTimer:(NSTimer*)timer {
	
	self.resetTimer = nil;

	[self moveNeedleToMin];
	
	MDLog(@"Timer triggers needle reset");
}


- (void)moveNeedleToMin {
	
	self.currVelocity = 0;

	self.needleView.transform = self.minRotationTransform;
}


- (void)moveNeedleWithTimer:(NSTimer*)timer {

	self.velocityTimer = nil;

	CGFloat velocity = ((NSNumber*)timer.userInfo).floatValue;
	[self moveNeedleWithVelocity:velocity];
	
	MDLog(@"Timer triggers needle move");
}


- (void)moveNeedleWithVelocity:(CGFloat)velocity {

	self.currVelocity = velocity;
	
	// Calculate velocity of pan motion
	self.maxVelocity = MAX(self.maxVelocity, velocity);
	MDLog(@"Velocity: curr:%.2f, max:%.2f", velocity, self.maxVelocity);
	
	// Calculate proportion of current velocity to velocity limit
	CGFloat velocityProportion = velocity / LIMIT_VELOCITY;
	//	MDLog(@"Velocity proportion: %.2f", velocityProportion);
	
	// Calculate proportion of RPM needle degree range
	CGFloat degrees = MIN(RANGE_DEGREES * velocityProportion, RANGE_DEGREES);
	//	MDLog(@"Degrees: %.2f", degrees);
	
	// Move needle in degree range proportionate to velocity
	self.needleView.transform = CGAffineTransformRotate(self.minRotationTransform, RADIANS(degrees));
}


@end

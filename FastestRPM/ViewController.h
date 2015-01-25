//
//  ViewController.h
//  FastestRPM
//
//  Created by Johnny on 2015-01-24.
//  Copyright (c) 2015 Empath Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>


#
# pragma mark - Interface
#

@interface ViewController : UIViewController

# pragma mark Properties

@property (weak, nonatomic) IBOutlet UIImageView *needleView;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;

@end


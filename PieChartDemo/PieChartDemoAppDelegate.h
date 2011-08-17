//
//  PieChartDemoAppDelegate.h
//  PieChartDemo
//
//  Created by Eric Yuen on 11-8-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PieChartDemoViewController;

@interface PieChartDemoAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PieChartDemoViewController *viewController;

@end

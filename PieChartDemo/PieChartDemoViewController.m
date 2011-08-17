//
//  PieChartDemoViewController.m
//  PieChartDemo
//
//  Created by Eric Yuen on 11-8-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PieChartDemoViewController.h"
#import "PieChartView.h"

@implementation PieChartDemoViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *valueArray = [[NSMutableArray alloc] initWithObjects:
                                  [NSNumber numberWithInt:1], 
                                  [NSNumber numberWithInt:1], 
                                  [NSNumber numberWithInt:1], 
                                  [NSNumber numberWithInt:3], 
                                  [NSNumber numberWithInt:2], 
                                  nil];
    
    NSMutableArray *colorArray = [[NSMutableArray alloc] initWithObjects:
                                  [UIColor blueColor],
                                  [UIColor redColor],
                                  [UIColor whiteColor],
                                  [UIColor greenColor],
                                  [UIColor purpleColor],
                                  nil];
    // 必须先创建一个相同大小的container view，再将PieChartView add上去
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake((320 - 250) / 2, 50, 250, 250)];
    PieChartView* pieView = [[PieChartView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
    [container addSubview:pieView];
    pieView.mValueArray = [NSMutableArray arrayWithArray:valueArray];
    pieView.mColorArray = [NSMutableArray arrayWithArray:colorArray];
    pieView.mInfoTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 350, 300, 80)];
    pieView.mInfoTextView.backgroundColor = [UIColor clearColor];
    pieView.mInfoTextView.editable = NO;
    pieView.mInfoTextView.userInteractionEnabled = NO;
    [self.view addSubview:container];
    [self.view addSubview:pieView.mInfoTextView];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

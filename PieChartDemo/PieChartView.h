//
//  PieChartView.h
//  PeiViewTest
//
//  Created by Eric Yuen on 11-8-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PieChartView : UIView {
    float               mZeroAngle;
    NSMutableArray     *mValueArray;
    NSMutableArray     *mColorArray;
    NSMutableArray     *mThetaArray;
    
    BOOL                isAnimating;
    BOOL                isTapStopped;
    BOOL                isAutoRotation;
    float               mAbsoluteTheta;
    float               mRelativeTheta;
    UITextView         *mInfoTextView;
    
    float               mDragSpeed;
    NSDate             *mDragBeforeDate;
    float               mDragBeforeTheta;
    NSTimer            *mDecelerateTimer;
}

@property (nonatomic)         float           mZeroAngle;
@property (nonatomic)         BOOL            isAutoRotation;
@property (nonatomic, retain) NSMutableArray *mValueArray;
@property (nonatomic, retain) NSMutableArray *mColorArray;
@property (nonatomic, retain) UITextView     *mInfoTextView;

@end
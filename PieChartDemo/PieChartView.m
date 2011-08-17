//
//  PieChartView.m
//  PeiViewTest
//
//  Created by Eric Yuen on 11-8-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PieChartView.h"

#define K_EPSINON        (1e-127)
#define IS_ZERO_FLOAT(X) (X < K_EPSINON && X > -K_EPSINON)

#define K_FRICTION              15.0f   // 摩擦系数
#define K_MAX_SPEED             30.0f
#define K_POINTER_ANGLE         (M_PI / 2)

@interface PieChartView(Private)  
- (void)timerStop;
- (void)tapStopped;
- (void)decelerate;

@end

@implementation PieChartView

@synthesize mZeroAngle;
@synthesize mValueArray;
@synthesize mColorArray;
@synthesize mInfoTextView;
@synthesize isAutoRotation;

#pragma mark -
#pragma mark Initialize
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        mRelativeTheta = 0.0;
        isAnimating = NO;
        isTapStopped = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int wedges = [mValueArray count];
    if (wedges > [mColorArray count]) {
        NSLog(@"Number of colors is not enough: please add %d kinds of colors.",wedges - [mColorArray count]);
        for (int i= [mColorArray count]; i<wedges; ++i) {
            [mColorArray addObject:[UIColor whiteColor]];
        }
    }
    
    mThetaArray = [[NSMutableArray alloc] initWithCapacity:wedges];
    
    float sum = 0.0;
    for (int i = 0; i < wedges; ++i) {
        sum += [[mValueArray objectAtIndex:i] floatValue];
    }
    float frac = 2.0 * M_PI / sum;
    
    int centerX = rect.size.width / 2.0;
    int centerY = rect.size.height / 2.0;
    int radius  = (centerX > centerY ? centerX : centerY);
    
    float startAngle = mZeroAngle;
    float endAngle   = mZeroAngle;
    for (int i = 0; i < wedges; ++i) {
        startAngle = endAngle;
        endAngle  += [[mValueArray objectAtIndex:i] floatValue] * frac;
        [mThetaArray addObject:[NSNumber numberWithFloat:endAngle]];
        [[mColorArray objectAtIndex:i] setFill];
        CGContextMoveToPoint(context, centerX, centerY);
        CGContextAddArc(context, centerX, centerY, radius, startAngle, endAngle, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
}

- (void)dealloc {
    [mValueArray release],     mValueArray = nil;
    [mColorArray release],     mColorArray = nil;
    [mThetaArray release],     mThetaArray = nil;
    [mInfoTextView release],   mInfoTextView = nil;
    [mDragBeforeDate release], mDragBeforeDate = nil;
    
    [mDecelerateTimer invalidate];
    [mDecelerateTimer release], mDecelerateTimer = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark handle rotation angle
- (float)thetaForX:(float)x andY:(float)y {
    if (IS_ZERO_FLOAT(y)) {
        if (x < 0) {
            return M_PI;
        } else {
            return 0;
        }
    }
    
    float theta = atan(y / x);
    if (x < 0 && y > 0) {
        theta = M_PI + theta;
    } else if (x < 0 && y < 0) {
        theta = M_PI + theta;
    } else if (x > 0 && y < 0) {
        theta = 2 * M_PI + theta;
    }
    return theta;
}

/* 计算将当前以相对角度为单位的触摸点旋转到绝对角度为newTheta的位置所需要旋转到的角度(*_*!真尼玛拗口) */
- (float)rotationThetaForNewTheta:(float)newTheta {
    float rotationTheta;
    if (mRelativeTheta > (3 * M_PI / 2) && (newTheta < M_PI / 2)) {
        rotationTheta = newTheta + (2 * M_PI - mRelativeTheta);
    } else {
        rotationTheta = newTheta - mRelativeTheta;
    }
    return rotationTheta;
}

- (float)thetaForTouch:(UITouch *)touch onView:view {
    CGPoint location = [touch locationInView:view];
    float xOffset    = self.bounds.size.width / 2;
    float yOffset    = self.bounds.size.height / 2;
    float centeredX  = location.x - xOffset;
    float centeredY  = location.y - yOffset;
    
    return [self thetaForX:centeredX andY:centeredY];
}

#pragma mark -
#pragma mark Private & handle rotation
- (void)timerStop {
    [mDecelerateTimer invalidate];
    mDecelerateTimer = nil;
    mDragSpeed = 0;
    isAnimating = NO;

    return;
}

- (void)animationDidStop:(NSString*)str finished:(NSNumber*)flag context:(void*)context {
    isAutoRotation = NO;
}

- (void)tapStopped {
    int tapAreaIndex;
    
    for (tapAreaIndex = 0; tapAreaIndex < [mThetaArray count]; tapAreaIndex++) {
        if (mRelativeTheta < [[mThetaArray objectAtIndex:tapAreaIndex] floatValue]) {
            break;
        } 
    }
    
    if (tapAreaIndex == 0) {
        mRelativeTheta = [[mThetaArray objectAtIndex:0] floatValue] / 2;
    } else {
        mRelativeTheta = [[mThetaArray objectAtIndex:tapAreaIndex] floatValue]
                       - (([[mThetaArray objectAtIndex:tapAreaIndex] floatValue]
                       - [[mThetaArray objectAtIndex:tapAreaIndex - 1] floatValue]) / 2);
    }
    
    isAutoRotation = YES;
    [UIView beginAnimations:@"tap stopped" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    self.transform = CGAffineTransformMakeRotation([self rotationThetaForNewTheta:K_POINTER_ANGLE]);
    [UIView commitAnimations];

    return;
}

- (void)decelerate {
    if (mDragSpeed > 0) {
        mDragSpeed -= (K_FRICTION / 100);
        
        if (mDragSpeed < 0.01) {
            [self timerStop];
        }
        
        mAbsoluteTheta += (mDragSpeed / 100); 
        if ((M_PI * 2) < mAbsoluteTheta) {
            mAbsoluteTheta -= (M_PI * 2);
        }
    } else if (mDragSpeed < 0){
        mDragSpeed += (K_FRICTION /100);
        if (mDragSpeed > -0.01) {
            [self timerStop];
        }
        
        mAbsoluteTheta += (mDragSpeed / 100);
        if (0 > mAbsoluteTheta) {
            mAbsoluteTheta = (M_PI * 2) + mAbsoluteTheta;
        }
    }
    
    isAnimating = YES;
    [UIView beginAnimations:@"pie rotation" context:nil];
    [UIView setAnimationDuration:0.01];
    self.transform = CGAffineTransformMakeRotation([self rotationThetaForNewTheta:mAbsoluteTheta]);
    
    [UIView commitAnimations];
    
    return;
}

#pragma mark -
#pragma mark Responder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if (isAutoRotation) {
        return;
    }
    
    isTapStopped = IS_ZERO_FLOAT(mDragSpeed);

    if ([mDecelerateTimer isValid]) {
        [self timerStop];
    }

    UITouch *touch   = [touches anyObject];
    mAbsoluteTheta   = [self thetaForTouch:touch onView:self.superview];
    mRelativeTheta   = [self thetaForTouch:touch onView:self];
    mDragBeforeDate  = [[NSDate date] retain];
    mDragBeforeTheta = 0.0f;
    return;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (isAutoRotation) {
        return;
    }
    
    isAnimating = YES;
    UITouch *touch = [touches anyObject];
    
    // 取得当前触点的theta值
    mAbsoluteTheta = [self thetaForTouch:touch onView:self.superview];
    
    // 计算速度
    NSTimeInterval dragInterval = [mDragBeforeDate timeIntervalSinceNow];
    
    /*由于theta大于2*PI后自动归零,因此此处需判断是否是在0度前后拖动 */
    if (fabsf(mAbsoluteTheta - mDragBeforeTheta) > M_PI) {    // 应判断是否#约等于#2PI. 
        if (mAbsoluteTheta > mDragBeforeTheta) {  // 反方向转动
            mDragSpeed = (mAbsoluteTheta - (mDragBeforeTheta + 2 * M_PI)) / fabs(dragInterval);
        } else {        // 正向转动
            mDragSpeed = ((mAbsoluteTheta + 2 * M_PI) - mDragBeforeTheta) / fabs(dragInterval);
        }
    } else {
        mDragSpeed = (mAbsoluteTheta - mDragBeforeTheta) / fabs(dragInterval);
    }
    [mInfoTextView setText:
     [NSString stringWithFormat:
      @"relative theta   = %.2f\nabsolute theta   = %.2f\nrotation theta   = %.2f\nspeed = %f", 
      mRelativeTheta, mAbsoluteTheta, [self rotationThetaForNewTheta:mAbsoluteTheta], mDragSpeed]];     
    [UIView beginAnimations:@"pie rotation" context:nil];
    [UIView setAnimationDuration:1];
    self.transform = CGAffineTransformMakeRotation([self rotationThetaForNewTheta:mAbsoluteTheta]);
    
    [UIView commitAnimations];
    isAnimating = NO;
    
    mDragBeforeTheta = mAbsoluteTheta;
    mDragBeforeDate = [[NSDate date] retain];
    
    return;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isAutoRotation) {
        return;
    }
    
    if (IS_ZERO_FLOAT(mDragSpeed)) {
        if (isTapStopped) {
            [self tapStopped];
            
            return;
        } else {
            return;
        }
    } else if ((fabsf(mDragSpeed) > K_MAX_SPEED)) {
        mDragSpeed = (mDragSpeed > 0) ? K_MAX_SPEED : -K_MAX_SPEED;
    }
    NSTimer * timer = [NSTimer timerWithTimeInterval:0.01
											  target:self
											selector:@selector(decelerate)
											userInfo:nil 
											 repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    mDecelerateTimer = timer;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}
@end
//
//  UIView+Frame.h
//  Being
//
//  Created by xiaofeng on 15/10/15.
//  Copyright © 2015年 Being Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

@property (assign, nonatomic) CGFloat frameX;
@property (assign, nonatomic) CGFloat frameY;
@property (assign, nonatomic) CGPoint frameOrigin;
@property (assign, nonatomic) CGFloat frameWidth;
@property (assign, nonatomic) CGFloat frameHeight;
@property (assign, nonatomic) CGSize frameSize;

@property (assign, nonatomic) CGFloat frameXAndWidth;
@property (assign, nonatomic) CGFloat frameYAndHeight;

@property (readonly, nonatomic) CGPoint boundsCenter;
@property (readonly, nonatomic) CGFloat boundsCenterX;
@property (readonly, nonatomic) CGFloat boundsCenterY;
@property (readonly, nonatomic) CGFloat boundsWidth;
@property (readonly, nonatomic) CGFloat boundsHeight;

@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;

@property (assign, nonatomic) CGPoint leftTop;
@property (assign, nonatomic) CGPoint leftCenter;
@property (assign, nonatomic) CGPoint leftBottom;
@property (assign, nonatomic) CGPoint topCenter;
@property (assign, nonatomic) CGPoint bottomCenter;
@property (assign, nonatomic) CGPoint rightTop;
@property (assign, nonatomic) CGPoint rightCenter;
@property (assign, nonatomic) CGPoint rightBottom;

/*
 wilson add
 */
@property (nonatomic) CGFloat left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGPoint origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  size;        ///< Shortcut for frame.size.


@end

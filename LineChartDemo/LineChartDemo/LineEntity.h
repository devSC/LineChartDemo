//
//  LineEntity.h
//  YKLineChartView
//
//  Created by chenyk on 15/12/9.
//  Copyright © 2015年 chenyk. All rights reserved.
//  https://github.com/chenyk0317/YKLineChartView

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface LineEntity : NSObject
@property (nonatomic) CGFloat open;
@property (nonatomic) CGFloat high;
@property (nonatomic) CGFloat low;
@property (nonatomic) CGFloat close;
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) NSString * date;

@property (nonatomic) CGFloat volume;
@property (nonatomic) CGFloat ma5;
@property (nonatomic) CGFloat ma10;
@property (nonatomic) CGFloat ma20;
@property (nonatomic) CGFloat preClosePx;
@property (strong, nonatomic) NSString * rate;

@end


@interface TimeLineEntity : NSObject
@property (strong, nonatomic) NSString * currtTime;
@property (nonatomic) CGFloat preClosePx;
@property (nonatomic) CGFloat avgPirce;
@property (nonatomic) CGFloat lastPirce;
@property (nonatomic) CGFloat totalVolume;
@property (nonatomic) CGFloat volume;
@property (nonatomic) CGFloat trade;
@property (strong, nonatomic) NSString * rate;

@end

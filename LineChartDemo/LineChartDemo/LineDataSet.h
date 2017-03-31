//
//  LineDataSet.h
//  YKLineChartView
//
//  Created by chenyk on 15/12/9.
//  Copyright © 2015年 chenyk. All rights reserved.
//  

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface LineDataSet : NSObject
@property (strong, nonatomic) NSMutableArray * data;
@property (nonatomic) CGFloat highlightLineWidth;
@property (strong, nonatomic) UIColor  * highlightLineColor;
@property (strong, nonatomic) UIColor * candleRiseColor;
@property (strong, nonatomic) UIColor * candleFallColor;
@property (strong, nonatomic) UIColor * avgMA5Color;
@property (strong, nonatomic) UIColor * avgMA10Color;
@property (strong, nonatomic) UIColor * avgMA20Color;
@property (nonatomic) CGFloat  avgLineWidth;
@property (nonatomic) CGFloat candleTopBottmLineWidth;


@end


@interface TimeDataset : NSObject
@property (strong, nonatomic) NSMutableArray * data;
@property (nonatomic) CGFloat highlightLineWidth;
@property (strong, nonatomic) UIColor  * highlightLineColor;
@property (nonatomic) CGFloat  lineWidth;
@property (strong, nonatomic) UIColor * priceLineCorlor;
@property (strong, nonatomic) UIColor * avgLineCorlor;

@property (strong, nonatomic) UIColor * volumeRiseColor;
@property (strong, nonatomic) UIColor * volumeFallColor;
@property (strong, nonatomic) UIColor * volumeTieColor;

@property (nonatomic) BOOL drawFilledEnabled;
@property (strong, nonatomic) UIColor * fillStartColor;
@property (strong, nonatomic) UIColor * fillStopColor;
@property (nonatomic) CGFloat fillAlpha;


@end

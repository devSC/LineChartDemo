//
//  LineChartView.h
//  NHTest
//
//  Created by Wilson Yuan on 2017/3/30.
//  Copyright © 2017年 Wilson-Yuan. All rights reserved.
//

#import "NHChartViewBase.h"
#import "LineDataSet.h"
@interface LineChartView : NHChartViewBase

//上部折线图所占整体比例
@property (nonatomic) CGFloat uperChartHeightScale;
//上部和下部之间的间距
@property (nonatomic) CGFloat uperSpaceToBottom;

///线宽
@property (nonatomic) CGFloat borderWidth;
///线颜色
@property (strong, nonatomic) UIColor *borderColor;
///格子颜色
@property (strong, nonatomic) UIColor *gridBackgroundColor;


///
@property (strong, nonatomic) NSDictionary *leftYAxisAttributedDic;
@property (strong, nonatomic) NSDictionary *xAxisAttributedDic;
@property (strong, nonatomic) NSDictionary *highlightAttributedDic;
@property (strong, nonatomic) NSDictionary *defaultAttributedDic;


@property (nonatomic) CGFloat offsetMaxPrice;

////闪烁点
@property (nonatomic) CGFloat candleWidth;
@property (nonatomic) CGFloat candleMaxWidth;
@property (nonatomic) CGFloat candleMinWidth;

//底部柱状图的最小单位比例
@property (nonatomic) CGFloat volumeCoordsScale;
//折线图的最小单位比例
@property (nonatomic) CGFloat candleCoordsScale;
//UNKNow
@property (nonatomic) CGFloat maxPrice;
@property (nonatomic) CGFloat minPrice;
@property (nonatomic) CGFloat maxVolume;
@property (nonatomic) BOOL isETF;

///长按高亮时出的线
@property (nonatomic) NSInteger highlightLineCurrentIndex;
@property (nonatomic) CGPoint highlightLineCurrentPoint;
@property (nonatomic) BOOL highlightLineCurrentEnabled;

///是否支持高亮显示
@property (nonatomic) BOOL highlightLineShowEnabled;

///是否显示最后一个点
@property (nonatomic) BOOL endPointShowEnabled;

///将左边的文字绘制在图中
@property (nonatomic) BOOL leftYAxisIsInChart;

///将右边的文字是否绘制
@property (nonatomic) BOOL rightYAxisDrawEnabled;


//是否绘制均线图
@property (nonatomic) BOOL isDrawAvgEnabled;
///
@property (nonatomic) NSInteger countOfTimes;

- (void)setData:(TimeDataset *)dataSet;

@end

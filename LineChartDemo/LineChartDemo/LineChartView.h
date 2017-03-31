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
@property (nonatomic,assign) CGFloat uperChartHeightScale;
//上部和下部之间的间距
@property (nonatomic,assign) CGFloat uperSpaceToBottom;

@property (nonatomic) CGFloat borderWidth;
@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) UIColor *gridBackgroundColor;


///
@property (strong, nonatomic) NSDictionary * leftYAxisAttributedDic;
@property (strong, nonatomic) NSDictionary * xAxisAttributedDic;
@property (strong, nonatomic) NSDictionary * highlightAttributedDic;
@property (strong, nonatomic) NSDictionary * defaultAttributedDic;


@property (nonatomic,assign)CGFloat offsetMaxPrice;

////闪烁点
@property (nonatomic,assign)CGFloat candleWidth;
@property (nonatomic,assign)CGFloat candleMaxWidth;
@property (nonatomic,assign)CGFloat candleMinWidth;

//底部柱状图的最小单位比例
@property (nonatomic,assign)CGFloat volumeCoordsScale;
//折线图的最小单位比例
@property (nonatomic,assign)CGFloat candleCoordsScale;
//UNKNow
@property (nonatomic,assign)CGFloat maxPrice;
@property (nonatomic,assign)CGFloat minPrice;
@property (nonatomic,assign)CGFloat maxVolume;
@property (nonatomic,assign)BOOL isETF;

///长按高亮时出的线
@property (nonatomic,assign)NSInteger highlightLineCurrentIndex;
@property (nonatomic,assign)CGPoint highlightLineCurrentPoint;
@property (nonatomic,assign)BOOL highlightLineCurrentEnabled;

///最后一个点
@property (nonatomic,assign)BOOL endPointShowEnabled;

//是否绘制均线图
@property (nonatomic,assign)BOOL isDrawAvgEnabled;
///
@property (nonatomic,assign)NSInteger countOfTimes;

- (void)setData:(TimeDataset *)dataSet;

@end

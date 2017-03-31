//
//  LineChartView.m
//  NHTest
//
//  Created by Wilson Yuan on 2017/3/30.
//  Copyright © 2017年 Wilson-Yuan. All rights reserved.
//

#import "LineChartView.h"
#import "UIView+Frame.h"
#import "LineEntity.h"

@interface LineChartView ()

@property (strong, nonatomic) TimeDataset *dataSet;

@property (nonatomic) NSInteger countOfshowCandle;
@property (nonatomic) NSInteger  startDrawIndex;

@property (strong, nonatomic) CALayer *breathingPoint;
@property (nonatomic)  CGFloat volumeWidth;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGesture;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation LineChartView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)setData:(TimeDataset *)dataSet {
    self.dataSet = dataSet;
    [self setNeedsDisplay];
}

- (void)initialize {
    
    self.borderWidth = 0.5;
    self.gridBackgroundColor = [UIColor whiteColor];
    self.borderColor = [UIColor colorWithRed:203/255.0 green:215/255.0 blue:224/255.0 alpha:1.0];
    self.uperChartHeightScale = 0.7;
    self.uperSpaceToBottom = 25;
    self.candleCoordsScale = 0.f;
    [self addGestureRecognizer:self.longPressGesture];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    [self setCurrentDataMaxAndMin];
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    ///find max and min
    
    ///draw 坐标轴, 需要知道横纵单位, 最大和最低价格.
    CGContextSetFillColorWithColor(context, self.gridBackgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, self.borderWidth);
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    
    //绘制折线图区域边框
    CGContextStrokeRect(context, CGRectMake(self.contentLeft, self.contentTop, self.contentWidth, (self.uperChartHeightScale * self.contentHeight)));
    
    //绘制柱状图区域边框
    CGContextStrokeRect(context, CGRectMake(self.contentLeft, (self.uperChartHeightScale * self.contentHeight) + self.uperSpaceToBottom, self.contentWidth, self.contentBottom  - (self.uperChartHeightScale * self.contentHeight) - self.uperSpaceToBottom));
    
    //折线图区域横向中间线
    [self drawline:context startPoint:CGPointMake(self.contentLeft, (self.uperChartHeightScale * self.contentHeight) / 2 + self.contentTop) stopPoint:CGPointMake(self.contentRight, (self.uperChartHeightScale * self.contentHeight) / 2 + self.contentTop) color:self.borderColor lineWidth:self.borderWidth / 2.0];
    
    //折线图区域纵向中间线
    [self drawline:context startPoint:CGPointMake(self.contentLeft + self.contentWidth / 2.0, self.contentTop) stopPoint:CGPointMake(self.contentLeft + self.contentWidth / 2.0, self.height * self.uperChartHeightScale + self.contentTop) color:self.borderColor lineWidth:self.borderWidth / 2.0];
    
    //绘制坐标轴中的文字
    [self drawTimeLabel:context];
    
    //画点并连接成线
    if (self.dataSet.data.count > 0) {
        [self drawLineChart:context];
    }
    
    //绘制详细文字
    [self drawLabelPrice:context];
}
- (void)setCurrentDataMaxAndMin {
    
    
    if (self.dataSet.data.count > 0) {
        self.maxPrice = CGFLOAT_MIN;
        self.minPrice = CGFLOAT_MAX;
        self.maxVolume = CGFLOAT_MIN;
        self.offsetMaxPrice = CGFLOAT_MIN;
        for (NSInteger i = 0; i < self.dataSet.data.count; i++) {
            TimeLineEntity *entity = [self.dataSet.data objectAtIndex:i];
            
            self.offsetMaxPrice = self.offsetMaxPrice >fabs(entity.lastPirce-entity.preClosePx)?self.offsetMaxPrice:fabs(entity.lastPirce-entity.preClosePx);
            if (entity.avgPirce) {
                self.offsetMaxPrice = self.offsetMaxPrice > fabs(entity.avgPirce - entity.preClosePx)?self.offsetMaxPrice:fabs(entity.avgPirce - entity.preClosePx);
            }
            self.maxVolume = self.maxVolume >entity.volume ? self.maxVolume : entity.volume;
        }
        self.maxPrice =((TimeLineEntity *)[self.dataSet.data firstObject]).preClosePx + self.offsetMaxPrice;
        self.minPrice =((TimeLineEntity *)[self.dataSet.data firstObject]).preClosePx - self.offsetMaxPrice;
        
        if (self.maxPrice == self.minPrice) {
            self.maxPrice = self.maxPrice + 0.01;
            self.minPrice = self.minPrice - 0.01;
        }
        for (NSInteger i = 0; i < self.dataSet.data.count; i++) {
            TimeLineEntity  * entity = [self.dataSet.data objectAtIndex:i];
            if (entity.avgPirce != 0) {
                entity.avgPirce = entity.avgPirce < self.minPrice ? self.minPrice :entity.avgPirce;
                entity.avgPirce = entity.avgPirce > self.maxPrice ? self.maxPrice :entity.avgPirce;
            }
        }
        
        
    }
}

- (void)drawLabelPrice:(CGContextRef)context {
    
    UIColor * labelBGColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    NSDictionary * drawAttributes = self.leftYAxisAttributedDic?:self.defaultAttributedDic;
    //@2016-5-12 by Liuk, 价格统一往左移2个像素，价格标签把图标的线遮挡了
    NSString * maxPriceStr = [self handleStrWithPrice:self.maxPrice];
    NSMutableAttributedString * maxPriceAttStr = [[NSMutableAttributedString alloc]initWithString:maxPriceStr attributes:drawAttributes];
    CGSize sizeMaxPriceAttStr = [maxPriceAttStr size];
    CGRect maxPriceRect = CGRectMake(self.contentLeft - (self.leftYAxisIsInChart?0:sizeMaxPriceAttStr.width+2), self.contentTop, sizeMaxPriceAttStr.width, sizeMaxPriceAttStr.height);
    [self drawRect:context rect:maxPriceRect color:labelBGColor];
    [self drawLabel:context attributesText:maxPriceAttStr rect:maxPriceRect];
    
    NSString * midPriceStr = [self handleStrWithPrice:(self.maxPrice+self.minPrice)/2.0];
    NSMutableAttributedString * midPriceAttStr = [[NSMutableAttributedString alloc]initWithString:midPriceStr attributes:drawAttributes];
    CGSize sizeMidPriceAttStr = [midPriceAttStr size];
    CGRect midPriceRect = CGRectMake(self.contentLeft - (self.leftYAxisIsInChart?0:sizeMidPriceAttStr.width+2), ((self.uperChartHeightScale * self.contentHeight)/2.0 + self.contentTop)-sizeMidPriceAttStr.height/2.0, sizeMidPriceAttStr.width, sizeMidPriceAttStr.height);
    [self drawRect:context rect:midPriceRect color:labelBGColor];
    [self drawLabel:context attributesText:midPriceAttStr rect:midPriceRect];
    
    NSString * minPriceStr = [self handleStrWithPrice:self.minPrice];
    NSMutableAttributedString * minPriceAttStr = [[NSMutableAttributedString alloc]initWithString:minPriceStr attributes:drawAttributes];
    CGSize sizeMinPriceAttStr = [minPriceAttStr size];
    CGRect minPriceRect = CGRectMake(self.contentLeft - (self.leftYAxisIsInChart?0:sizeMinPriceAttStr.width+2), ((self.uperChartHeightScale * self.contentHeight) + self.contentTop - sizeMinPriceAttStr.height ), sizeMinPriceAttStr.width, sizeMinPriceAttStr.height);
    [self drawRect:context rect:minPriceRect color:labelBGColor];
    [self drawLabel:context attributesText:minPriceAttStr rect:minPriceRect];
    
    NSMutableAttributedString * zeroVolumeAttStr = [[NSMutableAttributedString alloc]initWithString:[self handleShowWithVolume:self.maxVolume] attributes:drawAttributes];
    CGSize zeroVolumeAttStrSize = [zeroVolumeAttStr size];
    CGRect zeroVolumeRect = CGRectMake(self.contentLeft - (self.leftYAxisIsInChart?0:zeroVolumeAttStrSize.width+2), self.contentBottom - zeroVolumeAttStrSize.height, zeroVolumeAttStrSize.width, zeroVolumeAttStrSize.height);
    [self drawRect:context rect:zeroVolumeRect color:labelBGColor];
    [self drawLabel:context attributesText:zeroVolumeAttStr rect:zeroVolumeRect];
    
    NSString * maxVolumeStr = [self handleShowNumWithVolume:self.maxVolume];
    NSMutableAttributedString * maxVolumeAttStr = [[NSMutableAttributedString alloc]initWithString:maxVolumeStr attributes:drawAttributes];
    CGSize maxVolumeAttStrSize = [maxVolumeAttStr size];
    CGRect maxVolumeRect = CGRectMake(self.contentLeft - (self.leftYAxisIsInChart?0:maxVolumeAttStrSize.width+2), (self.uperChartHeightScale * self.contentHeight)+self.uperSpaceToBottom, maxVolumeAttStrSize.width, maxVolumeAttStrSize.height);
    [self drawRect:context rect:maxVolumeRect color:labelBGColor];
    [self drawLabel:context attributesText:maxVolumeAttStr rect:maxVolumeRect];
    
    
    if (self.rightYAxisDrawEnabled) {
        NSString * maxRateStr = [self handleRateWithPrice:self.maxPrice originPX:(self.maxPrice+self.minPrice)/2.0];
        NSMutableAttributedString * maxRateAttStr = [[NSMutableAttributedString alloc]initWithString:maxRateStr attributes:drawAttributes];
        CGSize sizeMaxRateAttStr = [maxRateAttStr size];
        CGRect maxRateRect = CGRectMake(self.contentRight- (self.leftYAxisIsInChart?sizeMaxRateAttStr.width:0), self.contentTop, sizeMaxRateAttStr.width, sizeMaxRateAttStr.height);
        [self drawRect:context rect:maxRateRect color:labelBGColor];
        [self drawLabel:context attributesText:maxRateAttStr rect:maxRateRect];
        
        NSString * minRateStr = [self handleRateWithPrice:self.minPrice originPX:(self.maxPrice+self.minPrice)/2.0];
        NSMutableAttributedString * minRateAttStr = [[NSMutableAttributedString alloc]initWithString:minRateStr attributes:drawAttributes];
        CGSize sizeMinRateAttStr = [minRateAttStr size];
        CGRect minRateRect = CGRectMake(self.contentRight-(self.leftYAxisIsInChart?sizeMinRateAttStr.width:0), ((self.uperChartHeightScale * self.contentHeight) + self.contentTop - sizeMinRateAttStr.height ), sizeMinRateAttStr.width, sizeMinRateAttStr.height);
        [self drawRect:context rect:minRateRect color:labelBGColor];
        [self drawLabel:context attributesText:minRateAttStr rect:minRateRect];
    }
    
}

- (void)drawTimeLabel:(CGContextRef)context {
    
    NSDictionary * drawAttributes = self.xAxisAttributedDic ?: self.defaultAttributedDic;
    
    NSMutableAttributedString * startTimeAttStr = [[NSMutableAttributedString alloc]initWithString:@"9:30" attributes:drawAttributes];
    CGSize sizeStartTimeAttStr = [startTimeAttStr size];
    [self drawLabel:context attributesText:startTimeAttStr rect:CGRectMake(self.contentLeft, (self.uperChartHeightScale * self.contentHeight+self.contentTop), sizeStartTimeAttStr.width, sizeStartTimeAttStr.height)];
    
    NSMutableAttributedString * midTimeAttStr = [[NSMutableAttributedString alloc]initWithString:@"11:30/13:00" attributes:drawAttributes];
    CGSize sizeMidTimeAttStr = [midTimeAttStr size];
    [self drawLabel:context attributesText:midTimeAttStr rect:CGRectMake(self.contentWidth/2.0 + self.contentLeft - sizeMidTimeAttStr.width/2.0, (self.uperChartHeightScale * self.contentHeight+self.contentTop), sizeMidTimeAttStr.width, sizeMidTimeAttStr.height)];
    
    NSMutableAttributedString * stopTimeAttStr = [[NSMutableAttributedString alloc]initWithString:@"15:00" attributes:drawAttributes];
    CGSize sizeStopTimeAttStr = [stopTimeAttStr size];
    [self drawLabel:context attributesText:stopTimeAttStr rect:CGRectMake(self.contentRight -sizeStopTimeAttStr.width, (self.uperChartHeightScale * self.contentHeight+self.contentTop), sizeStopTimeAttStr.width, sizeStopTimeAttStr.height)];
    
}

///绘制折线图
- (void)drawLineChart:(CGContextRef)context {
    CGContextSaveGState(context);
    
//    NSInteger idx = self.startDrawIndex;
    //折线图的最小单位比例
    self.candleCoordsScale = (self.uperChartHeightScale * self.contentHeight) / (self.maxPrice - self.minPrice);
    //底部柱状图的最小单位比例
    self.volumeCoordsScale = (self.contentHeight - (self.uperChartHeightScale * self.contentHeight) - self.uperSpaceToBottom) / (self.maxVolume - 0);
    
    CGMutablePathRef fillPath = CGPathCreateMutable();
    for (NSInteger i = 0; i < self.dataSet.data.count; i ++) {
        //
        TimeLineEntity *entity = self.dataSet.data[i];
//        CGFloat open = (self.maxPrice - entity.open) * (self.candleCoordsScale) + self.contentTop;
//        CGFloat close = (self.maxPrice - entity.close) * self.candleCoordsScale + self.contentTop;
//        CGFloat high = (self.maxPrice - entity.high) * self.candleCoordsScale + self.contentTop;
//        CGFloat low = (self.maxPrice - entity.low) * self.candleCoordsScale + self.contentTop;
        CGFloat left = (self.volumeWidth * i + self.contentLeft) + self.volumeWidth / 6.0;
        
        CGFloat candleWidth = self.volumeWidth - self.volumeWidth / 6.0;
        CGFloat startX = left + candleWidth / 2.0;
        CGFloat yPrice = 0;
        UIColor *color = self.dataSet.volumeRiseColor;
        if (i > 0) {
            //绘制线需要2点
            TimeLineEntity *lastEntity = self.dataSet.data[i - 1];
            CGFloat lastX = startX - self.volumeWidth;
            CGFloat lastYPrice = (self.maxPrice - lastEntity.lastPirce) * self.candleCoordsScale + self.contentTop;
            yPrice = (self.maxPrice - entity.lastPirce) * self.candleCoordsScale + self.contentTop;
            
            //draw line
            [self drawline:context startPoint:CGPointMake(lastX, lastYPrice) stopPoint:CGPointMake(startX, yPrice) color:self.dataSet.priceLineCorlor lineWidth:self.dataSet.lineWidth];
            
            ///绘制均线
            if (self.isDrawAvgEnabled && lastEntity.avgPirce > 0 && entity.avgPirce > 0) {
                //y
                CGFloat lastYAvg = (self.maxPrice - lastEntity.avgPirce) * self.candleCoordsScale + self.contentTop;
                CGFloat yAvg = (self.maxPrice - entity.avgPirce) * self.candleCoordsScale + self.contentTop;
                
                [self drawline:context startPoint:CGPointMake(lastX, lastYAvg) stopPoint:CGPointMake(startX, yAvg) color:self.dataSet.avgLineCorlor lineWidth:self.dataSet.lineWidth];
            }
            
            //柱状图的颜色
            if (entity.lastPirce > lastEntity.lastPirce) {
                color = self.dataSet.volumeRiseColor;
            } else if (entity.lastPirce < lastEntity.lastPirce) {
                color = self.dataSet.volumeFallColor;
            } else  {
                color = self.dataSet.volumeTieColor;
            }
            
            if (i == 1) {
                CGPathMoveToPoint(fillPath, NULL, self.contentLeft, (self.uperChartHeightScale * self.contentHeight) + self.contentTop);
                CGPathAddLineToPoint(fillPath, NULL, self.contentLeft, lastYPrice);
                CGPathAddLineToPoint(fillPath, NULL, lastX, lastYPrice);
            } else {
                CGPathAddLineToPoint(fillPath, NULL, startX, yPrice);
            }
            //最后一个点
            if (i == self.dataSet.data.count - 1) {
                CGPathAddLineToPoint(fillPath, NULL, startX, yPrice);
                CGPathAddLineToPoint(fillPath, NULL, startX, (self.uperChartHeightScale * self.contentHeight) + self.contentTop);
                CGPathCloseSubpath(fillPath);
            }
        }
        
        //柱状图
        CGFloat volume = (entity.volume - 0) * self.volumeCoordsScale;
        [self drawRect:context rect:CGRectMake(left, self.contentBottom - volume, candleWidth, volume) color:color];
        
        //十字线
        if (self.highlightLineCurrentEnabled) {
            ///只对目前高亮的点进行绘制
            if (i == self.highlightLineCurrentIndex) {
                if (i == 0) {
                    yPrice = (self.maxPrice - entity.lastPirce) * self.candleCoordsScale + self.contentTop;
                }
                
//                TimeLineEntity *enitty;
//                if (i < self.dataSet.data.count) {
//                    entity
//                }
                
                [self drawHighlighted:context point:CGPointMake(startX, yPrice) idex:i value:entity color:self.dataSet.highlightLineColor lineWidth:self.dataSet.highlightLineWidth];
            }
        }
        
        if (self.endPointShowEnabled && i == self.dataSet.data.count - 1) {
            if (i != self.countOfTimes - 1) {
                self.breathingPoint.frame = CGRectMake(startX - 4 / 2, yPrice - 4/2, 4, 4);
            }
        }
    }
    
    //绘制渐变色
    if (self.dataSet.drawFilledEnabled && self.dataSet.data.count > 0) {
        [self drawLinearGradient:context path:fillPath alpha:self.dataSet.fillAlpha startColor:self.dataSet.fillStartColor.CGColor endColor:self.dataSet.fillStopColor.CGColor];
    }
    
    CGPathRelease(fillPath);
    CGContextRestoreGState(context);
    
    //绘制均线
//    if (self.isDrawAvgEnabled) {
//        for (NSInteger i = 0; i < self.dataSet.data.count; i ++) {
//            TimeLineEntity *entity = self.dataSet.data[i];
//            CGFloat left = (self.volumeWidth * i + self.contentLeft) + self.volumeWidth / 6.0;
//            CGFloat candleWidth = self.volumeWidth - self.volumeWidth / 6.0;
//            CGFloat startX = left + candleWidth / 2.0;
//            
//            if (i > 0) {
//                //last
//                TimeLineEntity *lastEntity = self.dataSet.data[i - 1];
//                CGFloat lastX = startX - self.volumeWidth;
//                
//                if (lastEntity.avgPirce > 0 && entity.avgPirce > 0) {
//                    //y
//                    CGFloat lastYAvg = (self.maxPrice - lastEntity.avgPirce) * self.candleCoordsScale + self.contentTop;
//                    CGFloat yAvg = (self.maxPrice - entity.avgPirce) * self.candleCoordsScale + self.contentTop;
//                    
//                    [self drawline:context startPoint:CGPointMake(lastX, lastYAvg) stopPoint:CGPointMake(startX, yAvg) color:self.dataSet.avgLineCorlor lineWidth:self.dataSet.lineWidth];
//                }
//            }
//        }
//    }
}

#pragma mark - Draw method
- (void)drawLinearGradient:(CGContextRef)context
                      path:(CGPathRef)path
                     alpha:(CGFloat)alpha
                startColor:(CGColorRef)startColor
                  endColor:(CGColorRef)endColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    
    //具体方向可根据需求修改
    CGPoint startPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextSetAlpha(context, alpha);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
}

- (void)drawHighlighted:(CGContextRef)context
                  point:(CGPoint)point
                   idex:(NSInteger)idex
                  value:(id)value
                  color:(UIColor *)color
              lineWidth:(CGFloat)lineWidth {
    //
    NSString * leftMarkerStr = @"";
    NSString * bottomMarkerStr = @"";
    NSString * rightMarkerStr = @"";
    NSString * volumeMarkerStr = @"";
    
    if ([value isKindOfClass:[TimeLineEntity class]]) {
        TimeLineEntity *entity = value;
        leftMarkerStr = [self handleStrWithPrice:entity.lastPirce];
        bottomMarkerStr = entity.currtTime;
        rightMarkerStr = entity.rate;
    } else if ([value isKindOfClass:[LineEntity class]]) {
        LineEntity *entity = value;
        leftMarkerStr = [self handleStrWithPrice:entity.close];
        bottomMarkerStr = entity.date;
        volumeMarkerStr = [NSString stringWithFormat:@"%@%@", [self handleShowNumWithVolume:entity.volume], [self handleShowWithVolume:entity.volume]];
    } else {
        return;
    }
    
    if (!leftMarkerStr || !bottomMarkerStr || !rightMarkerStr) {
        return;
    }
    
    bottomMarkerStr = [@"" stringByAppendingFormat:@"%@ ", bottomMarkerStr];
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextBeginPath(context);
    
    //竖线
    CGContextMoveToPoint(context, point.x, self.contentTop);
    CGContextAddLineToPoint(context, point.x, self.contentBottom);
    CGContextStrokePath(context);
    
    //竖线
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.contentLeft, point.y);
    CGContextAddLineToPoint(context, self.contentRight, point.y);
    CGContextStrokePath(context);
    
    //小点
    CGFloat radius = 3.0;
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(point.x - (radius / 2.0), point.y - (radius / 2.0), radius, radius));
    
    //绘制相应文字
    NSDictionary * drawAttributes = self.highlightAttributedDic?:self.defaultAttributedDic;
    NSMutableAttributedString * leftMarkerStrAtt = [[NSMutableAttributedString alloc] initWithString:leftMarkerStr attributes:drawAttributes];
    
    CGSize leftMarkerStrAttSize = [leftMarkerStrAtt size];
    [self drawLabel:context attributesText:leftMarkerStrAtt rect:CGRectMake(self.contentLeft - leftMarkerStrAttSize.width,point.y - leftMarkerStrAttSize.height/2.0, leftMarkerStrAttSize.width, leftMarkerStrAttSize.height)];
    
    
    NSMutableAttributedString * bottomMarkerStrAtt = [[NSMutableAttributedString alloc] initWithString:bottomMarkerStr attributes:drawAttributes];
    
    CGSize bottomMarkerStrAttSize = [bottomMarkerStrAtt size];
    CGRect rect = CGRectMake(point.x - bottomMarkerStrAttSize.width/2.0,  ((self.uperChartHeightScale * self.contentHeight) + self.contentTop), bottomMarkerStrAttSize.width, bottomMarkerStrAttSize.height);
    if (rect.size.width + rect.origin.x > self.contentRight) {
        rect.origin.x = self.contentRight -rect.size.width;
    }
    if (rect.origin.x < self.contentLeft) {
        rect.origin.x = self.contentLeft;
    }
    [self drawLabel:context attributesText:bottomMarkerStrAtt rect:rect];
    
    
    NSMutableAttributedString * rightMarkerStrAtt = [[NSMutableAttributedString alloc] initWithString:rightMarkerStr attributes:drawAttributes];
    CGSize rightMarkerStrAttSize = [rightMarkerStrAtt size];
    [self drawLabel:context attributesText:rightMarkerStrAtt rect:CGRectMake(self.contentRight, point.y - rightMarkerStrAttSize.height/2.0, rightMarkerStrAttSize.width, rightMarkerStrAttSize.height)];
    
    NSMutableAttributedString * volumeMarkerStrAtt = [[NSMutableAttributedString alloc] initWithString:volumeMarkerStr attributes:drawAttributes];
    CGSize volumeMarkerStrAttSize = [volumeMarkerStrAtt size];
    [self drawLabel:context attributesText:volumeMarkerStrAtt rect:CGRectMake(self.contentLeft,  self.contentHeight * self.uperChartHeightScale + self.uperSpaceToBottom, volumeMarkerStrAttSize.width, volumeMarkerStrAttSize.height)];

}

- (void)drawRect:(CGContextRef)context
            rect:(CGRect)rect
           color:(UIColor*)color
{
    if ((rect.origin.x + rect.size.width) > self.contentRight) {
        return;
    }
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
}

- (void)drawLabel:(CGContextRef)context
   attributesText:(NSAttributedString *)attributesText
             rect:(CGRect)rect {
    [attributesText drawInRect:rect];
}

- (void)drawline:(CGContextRef)context
      startPoint:(CGPoint)startPoint
       stopPoint:(CGPoint)stopPoint
           color:(UIColor *)color
       lineWidth:(CGFloat)lineWitdth
{
    NSLog(@"start: %@, end: %@", NSStringFromCGPoint(startPoint), NSStringFromCGPoint(stopPoint));
    if (startPoint.x < self.contentLeft ||stopPoint.x >self.contentRight || startPoint.y <self.contentTop || stopPoint.y < self.contentTop) {
        return;
    }
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, lineWitdth);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, stopPoint.x, stopPoint.y);
    CGContextStrokePath(context);
}


#pragma mark - Private method
- (NSString *)handleShowWithVolume:(CGFloat)volume {
    volume = volume/100.0;
    
    if (volume < 10000.0) {
        return @"手 ";
    }else if (volume > 10000.0 && volume < 100000000.0){
        return @"万手 ";
    }else{
        return @"亿手 ";
    }
}
- (NSString *)handleShowNumWithVolume:(CGFloat)volume {
    volume = volume/100.0;
    if (volume < 10000.0) {
        return [NSString stringWithFormat:@"%.0f ",volume];
    }else if (volume > 10000.0 && volume < 100000000.0){
        return [NSString stringWithFormat:@"%.2f ",volume/10000.0];
    }else{
        return [NSString stringWithFormat:@"%.2f ",volume/100000000.0];
    }
}

- (NSString *)handleStrWithPrice:(CGFloat)price {
    if (self.isETF) {
        return [NSString stringWithFormat:@"%.3f ",price];
    }
    return [NSString stringWithFormat:@"%.2f ",price];
}

- (NSString *)handleRateWithPrice:(CGFloat)price
                         originPX:(CGFloat)originPX {
    
    if (0 == originPX) {
        return @"--";
    }
    CGFloat rate = (price - originPX)/originPX *100.00;
    if(rate >0){
        return [NSString stringWithFormat:@"+%.2f%@",rate,@"%"];
        
    }
    return [NSString stringWithFormat:@"%.2f%@",rate,@"%"];
}

- (void)handleLongPressGestureAction:(UIPanGestureRecognizer *)recognizer {
    if (!self.highlightLineShowEnabled) {
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint  point = [recognizer locationInView:self];
        
        if (point.x > self.contentLeft && point.x < self.contentRight && point.y >self.contentTop && point.y<self.contentBottom) {
            self.highlightLineCurrentEnabled = YES;
            [self getHighlightByTouchPoint:point];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint  point = [recognizer locationInView:self];
        
        if (point.x > self.contentLeft && point.x < self.contentRight && point.y >self.contentTop && point.y<self.contentBottom) {
            self.highlightLineCurrentEnabled = YES;
            [self getHighlightByTouchPoint:point];
        }
    }
    else {
        if (self.highlightLineCurrentEnabled) {
            self.highlightLineCurrentEnabled = NO;
        }
        [self setNeedsDisplay];
    }
}

- (void)getHighlightByTouchPoint:(CGPoint)point {
    
    self.highlightLineCurrentIndex = (NSInteger)((point.x - self.contentLeft)/self.volumeWidth);
    [self setNeedsDisplay];
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongTapGestureAction:)];
    }
    return _tapGesture;
}
- (void)handleLongTapGestureAction:(UITapGestureRecognizer *)recognizer {
    if (self.highlightLineCurrentEnabled) {
        self.highlightLineCurrentEnabled = NO;
    }
    [self setNeedsDisplay];
}
- (void)notifyDataSetChanged {
    [super notifyDataSetChanged];
    [self setNeedsDisplay];
}
- (void)notifyDeviceOrientationChanged {
    [super notifyDeviceOrientationChanged];
}


- (UILongPressGestureRecognizer *)longPressGesture
{
    if (!_longPressGesture) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGestureAction:)];
        _longPressGesture.minimumPressDuration = 0.5;
    }
    return _longPressGesture;
}

- (CALayer *)breathingPoint {
    if (!_breathingPoint) {
        _breathingPoint = [CAScrollLayer layer];
        [self.layer addSublayer:_breathingPoint];
        _breathingPoint.backgroundColor = [UIColor whiteColor].CGColor;
        _breathingPoint.cornerRadius = 2;
        _breathingPoint.masksToBounds = YES;
        _breathingPoint.borderWidth = 1;
        _breathingPoint.borderColor = self.dataSet.priceLineCorlor.CGColor;
        
        [_breathingPoint addAnimation:[self groupAnimationDurTimes:1.5f] forKey:@"breathingPoint"];
    }
    return _breathingPoint;
}
-(CABasicAnimation *)breathingLight:(float)time {
    CABasicAnimation *animation =[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.3f];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return animation;
}
-(CAAnimationGroup *)groupAnimationDurTimes:(float)time {
    
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)];
    scaleAnim.removedOnCompletion = NO;
    
    NSArray * array = @[[self breathingLight:time],scaleAnim];
    CAAnimationGroup *animation=[CAAnimationGroup animation];
    animation.animations= array;
    animation.duration=time;
    animation.repeatCount=MAXFLOAT;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    return animation;
}

- (CGFloat)volumeWidth {
    return self.contentWidth/self.countOfTimes;
}

- (NSDictionary *)defaultAttributedDic {
    if (!_defaultAttributedDic) {
        _defaultAttributedDic = @{NSFontAttributeName:[UIFont systemFontOfSize:10],NSBackgroundColorAttributeName:[UIColor clearColor]};
    }
    return _defaultAttributedDic;
}

@end

//
//  ViewController.m
//  LineChartDemo
//
//  Created by Wilson Yuan on 2017/3/31.
//  Copyright © 2017年 Wilson Yuan. All rights reserved.
//

#import "ViewController.h"
#import "LineChartView.h"
#import "LineEntity.h"
#import "LineDataSet.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet LineChartView *chartView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString * path =[[NSBundle mainBundle]pathForResource:@"data.plist" ofType:nil];
    NSArray * sourceArray = [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:@"data3"];
    NSMutableArray * timeArray = [NSMutableArray array];
    for (NSDictionary * dic in sourceArray) {
        TimeLineEntity * e = [[TimeLineEntity alloc]init];
        e.currtTime = dic[@"curr_time"];
        e.preClosePx = [dic[@"pre_close_px"] doubleValue];
        e.avgPirce = [dic[@"avg_pirce"] doubleValue];
        e.lastPirce = [dic[@"last_px"]doubleValue];
        e.volume = [dic[@"last_volume_trade"]doubleValue];
        e.rate = dic[@"rise_and_fall_rate"];
        [timeArray addObject:e];
    }
    
//    [self.chartView setupChartOffsetWithLeft:50 top:10 right:10 bottom:10];
    self.chartView.gridBackgroundColor = [UIColor whiteColor];
    self.chartView.borderColor = [UIColor colorWithRed:203/255.0 green:215/255.0 blue:224/255.0 alpha:1.0];
    self.chartView.borderWidth = .5;
    self.chartView.uperChartHeightScale = 0.7;
    self.chartView.uperSpaceToBottom = 25;
    self.chartView.countOfTimes = 242;
    self.chartView.endPointShowEnabled = YES;
    self.chartView.isDrawAvgEnabled = YES;
    
    TimeDataset * set  = [[TimeDataset alloc]init];
    set.data = timeArray;
    set.avgLineCorlor = [UIColor colorWithRed:253/255.0 green:179/255.0 blue:8/255.0 alpha:1.0];
    set.priceLineCorlor = [UIColor colorWithRed:24/255.0 green:96/255.0 blue:254/255.0 alpha:1.0];
    set.lineWidth = 1.f;
    set.highlightLineWidth = .8f;
    set.highlightLineColor = [UIColor colorWithRed:60/255.0 green:76/255.0 blue:109/255.0 alpha:1.0];
    
    set.volumeTieColor = [UIColor grayColor];
    set.volumeRiseColor = [UIColor colorWithRed:233/255.0 green:47/255.0 blue:68/255.0 alpha:1.0];
    set.volumeFallColor = [UIColor colorWithRed:33/255.0 green:179/255.0 blue:77/255.0 alpha:1.0];
    
    set.fillStartColor = [UIColor colorWithRed:24/255.0 green:96/255.0 blue:254/255.0 alpha:1.0];
    set.fillStopColor = [UIColor whiteColor];
    set.fillAlpha = .5f;
    set.drawFilledEnabled = YES;
//    self.chartView.delegate = self;
//    self.chartView.highlightLineShowEnabled = YES;
//    self.chartView.leftYAxisIsInChart = YES;
//    self.chartView.rightYAxisDrawEnabled = YES;
    [self.chartView setData:set];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

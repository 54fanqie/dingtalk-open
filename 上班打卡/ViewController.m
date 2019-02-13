//
//  ViewController.m
//  上班打卡
//
//  Created by 番茄 on 1/24/18.
//  Copyright © 2018 番茄. All rights reserved.
//

#import "ViewController.h"
#import "TimeDetailView.h"

@interface ViewController ()
// 这里变为了weak
@property (nonatomic, strong) NSTimer *timer;
@property(nonatomic,strong) TimeDetailView * timeDetailView;

@property(nonatomic,strong) NSString * setTime;
@property(nonatomic,strong) NSString * endTime;
@end

//开始打卡时间
static NSString * const StartDingTime = @"08";
static NSString * const WorkTime = @"09:00";



//结束打卡时间
static NSString * const EndDingTime = @"18";
static NSString * const WorkTimeEnd = @"19:00";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _timeDetailView = [[TimeDetailView alloc]init];
    _timeDetailView.currentTimeLab.text = self.getCurrentTime;
    
}
- (IBAction)startWorkAction:(id)sender {
    self.setTime = [self getTheRandomTime:@"AM"];
    self.endTime = WorkTime;
    _timeDetailView.titlelabel.text = @"上班打卡时间";
    _timeDetailView.setTimeLab.text = [NSString stringWithFormat:@"AM:%@",self.setTime];
    [self startTimer];
    [_timeDetailView showWithAnimation:YES];
}
- (IBAction)endWorkAction:(id)sender {
    self.setTime = [self getTheRandomTime:@"PM"];
    self.endTime = WorkTimeEnd;
    _timeDetailView.titlelabel.text = @"下班打卡时间";
    _timeDetailView.setTimeLab.text = [NSString stringWithFormat:@"PM:%@",self.setTime];
    [self startTimer];
    [_timeDetailView showWithAnimation:YES];
}

/**
 开始计时器
 */
-(void)startTimer{
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startTimeMonitoring) userInfo:nil repeats:YES];
    self.timer = timer;
}

-(void)startTimeMonitoring{
    _timeDetailView.currentTimeLab.text = self.getCurrentTime;
    if([self isOverTheWeekend]){
        return;
    }
    NSLog(@"%@--%@",self.setTime,self.endTime);
    //判断当前时间是否在规定时间范围内
    if([self judgeTimeByStartAndEnd:self.setTime withExpireTime:self.endTime]){
        NSURL *url = [NSURL URLWithString:@"dingtalk-open://"];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            NSLog(@"打卡成功");
            //取消定时器
            [self.timer invalidate];
            self.timer = nil;
        }];
    }
}


/**
 通过拼接获取上下班时间字符串
 
 @param dayOptions 时间区间：AM为上午，PM下午
 @return 返回打卡时间
 */
-(NSString*)getTheRandomTime:(NSString*)dayOptions{
    NSString * dingTimeStr;
    int minute = self.getTheArc4random;
    if ([dayOptions isEqualToString:@"AM"]) {
        dingTimeStr = [NSString stringWithFormat:@"%@:%d",StartDingTime,minute];
    }else{
        dingTimeStr = [NSString stringWithFormat:@"%@:%d",EndDingTime,10];
    }
    return dingTimeStr;
}


/**
 获取分针的随机数： 30 ~ 60范围
 @return 分针时刻随机数
 */
-(int)getTheArc4random{
    int y = 25 +  (arc4random() % 30);
    return y;
}


/**
 判断某个时间节点是否在指定的范围内：startTime ~ expireTime
 
 @param startTime 起始时间节点
 @param expireTime 结束时间节点
 @return yes标志在指定范围，no则相反
 */
- (BOOL)judgeTimeByStartAndEnd:(NSString *)startTime withExpireTime:(NSString *)expireTime {
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    // 时间格式,此处遇到过坑,建议时间HH大写,手机24小时进制和12小时禁止都可以完美格式化
    [dateFormat setDateFormat:@"HH:mm"];
    NSString * todayStr=[dateFormat stringFromDate:today];//将日期转换成字符串
    today=[ dateFormat dateFromString:todayStr];//转换成NSDate类型。日期置为方法默认日期
    //startTime格式为 02:22   expireTime格式为 12:44
    NSDate *start = [dateFormat dateFromString:startTime];
    NSDate *expire = [dateFormat dateFromString:expireTime];
    
    if ([today compare:start] == NSOrderedDescending && [today compare:expire] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}


/**
 获取当前时间 HH:mm:ss
 
 @return 返回当前时间
 */
-(NSString*)getCurrentTime {
    NSDateFormatter*formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString * dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}


/**
 判断当前时间是否是周末
 
 @return yes or no
 */
-(BOOL)isOverTheWeekend{
    NSString * week = [self  getWeekDayByDate:[NSDate date]];
    if([week isEqualToString:@"星期六"] ||[week isEqualToString:@"星期日"] ){
        return YES;
    }else{
        return NO;
    }
}

/**
 计算输入时间是星期几
 
 @param date 输入日期
 @return 返回周几
 */
- (NSString *)getWeekDayByDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekComp = [calendar components:NSCalendarUnitWeekday fromDate:date];
    NSInteger weekDayEnum = [weekComp weekday];
    NSString *weekDays = nil;
    switch (weekDayEnum) {
        case 1:
            weekDays = @"星期日";
            break;
        case 2:
            weekDays = @"星期一";
            break;
        case 3:
            weekDays = @"星期二";
            break;
        case 4:
            weekDays = @"星期三";
            break;
        case 5:
            weekDays = @"星期四";
            break;
        case 6:
            weekDays = @"星期五";
            break;
        case 7:
            weekDays = @"星期六";
            break;
        default:
            break;
    }
    return weekDays;
}

- (void)dealloc {
    [self.timer invalidate];
    NSLog(@"%s", __func__);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

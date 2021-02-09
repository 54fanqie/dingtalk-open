//
//  ViewController.m
//  上班打卡
//
//  Created by 番茄 on 1/24/18.
//  Copyright © 2018 番茄. All rights reserved.
//

#import "ViewController.h"
#import "TimeDetailView.h"
#import "LocationTransform.h"
#import "EventKit/EventKit.h"
#import "HolidayMessage.h"
@interface ViewController ()
// 这里变为了weak
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;
@property(nonatomic,strong) TimeDetailView * tdlView;
@property(nonatomic,strong) NSString * setTime;
@property(nonatomic,strong) NSString * endTime;
@property(nonatomic,strong) NSMutableDictionary * nsMu;
@end

//上班打卡时间区间
static NSString * const StartDingTime = @"08:40";
static NSString * const WorkTime = @"09:20";

//下班打卡时间区间
static NSString *  EndDingTime = @"18:30";
static NSString *  WorkTimeEnd = @"20:00";


static int count = 0;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //获取初始化，节假日数据
    [self paremStatutoryHolidays];
    NSString * day = self.getCurrentTimes;
    HolidayMessage * ho = [self.nsMu  objectForKey:day];
    NSLog(@"%hhu",ho.holiday);
    if (ho!=nil) {
        self.dateLab.text =[NSString stringWithFormat: @"%hhu  %@",ho.holiday,ho.name];
    }
}



/**
 开启上班打卡AM
 
 @param sender nil
 */
- (IBAction)startWorkAction:(id)sender {
    //从字符 : 中分隔成2个元素的数组
    NSArray * array = [StartDingTime componentsSeparatedByString:@":"];
    NSLog(@"array:%@",array);
    int minute = [self getTheArc4random:[[array objectAtIndex:1] intValue]];
    // 通过拼接获取上下班时间字符串
    self.setTime = [NSString stringWithFormat:@"%@:%d",[array objectAtIndex:0],minute];
    self.endTime = WorkTime;
    [self showPromptView:@"上班打卡时间" time:self.setTime];
    [self startTimer];
    
}

/**
 开启下班打卡PM
 
 @param sender nil
 */
- (IBAction)endWorkAction:(id)sender {
    //从字符 : 中分隔成2个元素的数组
    NSArray * array = [EndDingTime componentsSeparatedByString:@":"];
    NSLog(@"array:%@",array);
    int minute = [self getTheArc4random:[[array objectAtIndex:1] intValue]];
    // 通过拼接获取上下班时间字符串
    self.setTime = [NSString stringWithFormat:@"%@:%d",[array objectAtIndex:0],minute];
    self.endTime = WorkTimeEnd;
    [self showPromptView:@"下班打卡时间" time:self.setTime];
    [self startTimer];
   
}

/**
 获取分针的随机数： minute ~ 60范围
 @return 分针时刻随机数
 */
-(int)getTheArc4random:(int) minute{
    //防止时间写错了超过60分限制
    if (minute > 60) {
        NSLog(@"时间设置超过60限制");
        minute = minute - 60;
        [self getTheArc4random:minute];
    }
    int y = minute +  (arc4random() % (60 - minute));
    return y;
}
/**
 开始计时器
 */
-(void)startTimer{
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(startTimeMonitoring) userInfo:nil repeats:YES];
    self.timer = timer;
}

-(void)startTimeMonitoring{
    _tdlView.currentTimeLab.text = self.getCurrentTime;
    if([self isOverTheWeekend]){
        return;
    }
    NSLog(@"%@--%@",self.setTime,self.endTime);
    //判断当前时间是否在规定时间范围内
    if([self judgeTimeByStartAndEnd:self.setTime withExpireTime:self.endTime]){
        NSURL *url = [NSURL URLWithString:@"dingtalk-open://"];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
            if(success){
                NSLog(@"打卡成功");
                //取消定时器
                [self.timer invalidate];
                self.timer = nil;
            }else{
                NSLog(@"打卡失败，继续执行");
                count++;
                if (count>10) {
                    //取消定时器
                    [self.timer invalidate];
                    self.timer = nil;
                    _tdlView.currentTimeLab.text = @"调起钉钉打开失败，错过打卡时间！";
                }
            }
        }];
    }else{
        NSLog(@"还未到指定时间区间，或错过了打卡时间");
    }
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
    NSString * day = self.getCurrentTimes;
    HolidayMessage * ho = [self.nsMu  objectForKey:day];
    NSLog(@"%hhu",ho.holiday);
    return ho.holiday;
}
-(NSString*)getCurrentTimes {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置想要的格式，hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *dateNow = [NSDate date];
    //把NSDate按formatter格式转成NSString
    NSString *currentTime = [formatter stringFromDate:dateNow];
    return currentTime;
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

- (void)showPromptView:(NSString*)title time:(NSString*)time{
    TimeDetailView * timeDetailView = [[TimeDetailView alloc]init];
    timeDetailView.currentTimeLab.text = self.getCurrentTime;
    timeDetailView.titlelabel.text = title;
    timeDetailView.setTimeLab.text = [NSString stringWithFormat:@"PM:%@",time];
    _tdlView = timeDetailView;
    [timeDetailView showWithAnimation:YES];
    __weak ViewController *weakSelf = self;
    timeDetailView.closeBlock = ^{
        //取消定时器
        [weakSelf.timer invalidate];
        weakSelf.timer = nil;
    };
}
/**
 每年的法定节假日不定，从开源接口获取法定节假日数据：http://timor.tech/api/holiday
 */
- (void)paremStatutoryHolidays{
    NSString *jsonStr = @"{\"01-01\":{\"holiday\":true,\"name\":\"元旦\",\"wage\":3,\"date\":\"2021-01-01\",\"rest\":1},\"01-02\":{\"holiday\":true,\"name\":\"元旦\",\"wage\":2,\"date\":\"2021-01-02\",\"rest\":1},\"01-03\":{\"holiday\":true,\"name\":\"元旦\",\"wage\":2,\"date\":\"2021-01-03\",\"rest\":1},\"01-09\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-01-09\"},\"01-10\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-01-10\"},\"01-16\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-01-16\"},\"01-17\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-01-17\"},\"01-23\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-01-23\"},\"01-24\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-01-24\"},\"01-30\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-01-30\"},\"01-31\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-01-31\"},\"02-06\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-02-06\"},\"02-07\":{\"holiday\":false,\"name\":\"春节前调休\",\"after\":false,\"wage\":1,\"target\":\"春节\",\"date\":\"2021-02-07\",\"rest\":1},\"02-11\":{\"holiday\":true,\"name\":\"除夕\",\"wage\":2,\"date\":\"2021-02-11\",\"rest\":4},\"02-12\":{\"holiday\":true,\"name\":\"初一\",\"wage\":3,\"date\":\"2021-02-12\",\"rest\":1},\"02-13\":{\"holiday\":true,\"name\":\"初二\",\"wage\":3,\"date\":\"2021-02-13\",\"rest\":1},\"02-14\":{\"holiday\":true,\"name\":\"初三\",\"wage\":3,\"date\":\"2021-02-14\",\"rest\":1},\"02-15\":{\"holiday\":true,\"name\":\"初四\",\"wage\":2,\"date\":\"2021-02-15\",\"rest\":1},\"02-16\":{\"holiday\":true,\"name\":\"初五\",\"wage\":2,\"date\":\"2021-02-16\",\"rest\":1},\"02-17\":{\"holiday\":true,\"name\":\"初六\",\"wage\":2,\"date\":\"2021-02-17\",\"rest\":1},\"02-20\":{\"holiday\":false,\"name\":\"春节后调休\",\"after\":true,\"wage\":1,\"target\":\"春节\",\"date\":\"2021-02-20\"},\"02-21\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-02-21\"},\"02-27\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-02-27\"},\"02-28\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-02-28\"},\"03-06\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-03-06\"},\"03-07\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-03-07\"},\"03-13\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-03-13\"},\"03-14\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-03-14\"},\"03-20\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-03-20\"},\"03-21\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-03-21\"},\"03-27\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-03-27\"},\"03-28\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-03-28\"},\"04-03\":{\"holiday\":true,\"name\":\"清明节\",\"wage\":3,\"date\":\"2021-04-03\",\"rest\":26},\"04-04\":{\"holiday\":true,\"name\":\"清明节\",\"wage\":2,\"date\":\"2021-04-04\",\"rest\":1},\"04-05\":{\"holiday\":true,\"name\":\"清明节\",\"wage\":2,\"date\":\"2021-04-05\",\"rest\":1},\"04-10\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-04-10\"},\"04-11\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-04-11\"},\"04-17\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-04-17\"},\"04-18\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-04-18\"},\"04-24\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-04-24\"},\"04-25\":{\"holiday\":false,\"name\":\"劳动节前调休\",\"after\":false,\"wage\":1,\"target\":\"劳动节\",\"date\":\"2021-04-25\"},\"05-01\":{\"holiday\":true,\"name\":\"劳动节\",\"wage\":3,\"date\":\"2021-05-01\"},\"05-02\":{\"holiday\":true,\"name\":\"劳动节\",\"wage\":2,\"date\":\"2021-05-02\"},\"05-03\":{\"holiday\":true,\"name\":\"劳动节\",\"wage\":2,\"date\":\"2021-05-03\"},\"05-04\":{\"holiday\":true,\"name\":\"劳动节\",\"wage\":2,\"date\":\"2021-05-04\"},\"05-05\":{\"holiday\":true,\"name\":\"劳动节\",\"wage\":2,\"date\":\"2021-05-05\"},\"05-08\":{\"holiday\":false,\"name\":\"劳动节后调休\",\"after\":true,\"wage\":1,\"target\":\"劳动节\",\"date\":\"2021-05-08\"},\"05-09\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-05-09\"},\"05-15\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-05-15\"},\"05-16\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-05-16\"},\"05-22\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-05-22\"},\"05-23\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-05-23\"},\"05-29\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-05-29\"},\"05-30\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-05-30\"},\"06-05\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-06-05\"},\"06-06\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-06-06\"},\"06-12\":{\"holiday\":true,\"name\":\"端午节\",\"wage\":3,\"date\":\"2021-06-12\",\"rest\":11},\"06-13\":{\"holiday\":true,\"name\":\"端午节\",\"wage\":2,\"date\":\"2021-06-13\"},\"06-14\":{\"holiday\":true,\"name\":\"端午节\",\"wage\":2,\"date\":\"2021-06-14\"},\"06-19\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-06-19\"},\"06-20\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-06-20\"},\"06-26\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-06-26\"},\"06-27\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-06-27\"},\"07-03\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-07-03\"},\"07-04\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-07-04\"},\"07-10\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-07-10\"},\"07-11\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-07-11\"},\"07-17\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-07-17\"},\"07-18\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-07-18\"},\"07-24\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-07-24\"},\"07-25\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-07-25\"},\"07-31\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-07-31\"},\"08-01\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-08-01\"},\"08-07\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-08-07\"},\"08-08\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-08-08\"},\"08-14\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-08-14\"},\"08-15\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-08-15\"},\"08-21\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-08-21\"},\"08-22\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-08-22\"},\"08-28\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-08-28\"},\"08-29\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-08-29\"},\"09-04\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-09-04\"},\"09-05\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-09-05\"},\"09-11\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-09-11\"},\"09-12\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-09-12\"},\"09-18\":{\"holiday\":false,\"after\":false,\"name\":\"中秋节前调休\",\"wage\":1,\"target\":\"中秋节\",\"date\":\"2021-09-18\"},\"09-19\":{\"holiday\":true,\"name\":\"中秋节\",\"wage\":3,\"date\":\"2021-09-19\"},\"09-20\":{\"holiday\":true,\"name\":\"中秋节\",\"wage\":2,\"date\":\"2021-09-20\"},\"09-21\":{\"holiday\":true,\"name\":\"中秋节\",\"wage\":2,\"date\":\"2021-09-21\"},\"09-25\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-09-25\"},\"09-26\":{\"holiday\":false,\"after\":false,\"name\":\"国庆节前调休\",\"wage\":1,\"target\":\"国庆节\",\"date\":\"2021-09-26\",\"rest\":2},\"10-01\":{\"holiday\":true,\"name\":\"国庆节\",\"wage\":3,\"date\":\"2021-10-01\",\"rest\":7},\"10-02\":{\"holiday\":true,\"name\":\"国庆节\",\"wage\":3,\"date\":\"2021-10-02\"},\"10-03\":{\"holiday\":true,\"name\":\"国庆节\",\"wage\":3,\"date\":\"2021-10-03\"},\"10-04\":{\"holiday\":true,\"name\":\"国庆节\",\"wage\":2,\"date\":\"2021-10-04\"},\"10-05\":{\"holiday\":true,\"name\":\"国庆节\",\"wage\":2,\"date\":\"2021-10-05\"},\"10-06\":{\"holiday\":true,\"name\":\"国庆节\",\"wage\":2,\"date\":\"2021-10-06\"},\"10-07\":{\"holiday\":true,\"name\":\"国庆节\",\"wage\":2,\"date\":\"2021-10-07\"},\"10-09\":{\"holiday\":false,\"name\":\"国庆节后调休\",\"after\":true,\"wage\":1,\"target\":\"国庆节\",\"date\":\"2021-10-09\"},\"10-10\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-10-10\"},\"10-16\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-10-16\"},\"10-17\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-10-17\"},\"10-23\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-10-23\"},\"10-24\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-10-24\"},\"10-30\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-10-30\"},\"10-31\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-10-31\"},\"11-06\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-11-06\"},\"11-07\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-11-07\"},\"11-13\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-11-13\"},\"11-14\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-11-14\"},\"11-20\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-11-20\"},\"11-21\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-11-21\"},\"11-27\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-11-27\"},\"11-28\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-11-28\"},\"12-04\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-12-04\"},\"12-05\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-12-05\"},\"12-11\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-12-11\"},\"12-12\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-12-12\"},\"12-18\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-12-18\"},\"12-19\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-12-19\"},\"12-25\":{\"holiday\":true,\"name\":\"周六\",\"wage\":2,\"date\":\"2021-12-25\"},\"12-26\":{\"holiday\":true,\"name\":\"周日\",\"wage\":2,\"date\":\"2021-12-26\"}}";
    
    
    NSDictionary * dic = [self jsonToDic:jsonStr];
    self.nsMu = [[NSMutableDictionary alloc]init];
    for (NSString * key in dic.allKeys) {
        NSDictionary * holidayDic = [dic objectForKey:key];
        HolidayMessage * ho = [[HolidayMessage alloc]init];
        [ho convert:holidayDic];
        [self.nsMu  setValue:ho forKey:ho.date];
    }
}
-(NSDictionary*)jsonToDic:(NSString *)jsonStr{
    NSError *err = nil;
    //先将字符串转换成data格式
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    //再将data转成字典
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    //    NSLog(@"%@", dic.allValues);
    
    //    NSDictionary *data2 = [jsonStr objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    //    NSLog(@"%@", data2.allValues);
    return dic;
}

/**
 手动设置下班时间
 @param sender nil
 */
- (IBAction)settingAction:(id)sender {
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"您已修改下班打开时间20:00~21:00" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * alt1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        EndDingTime = @"20:00";
        WorkTimeEnd = @"21:00";
    }];
    [alertVC addAction:alt1];
    [self presentViewController:alertVC animated:YES completion:nil];
}

/**
test 坐标转换也可直接使用高德坐标转换：https://lbs.amap.com/console/show/picker
 */
-(void)locationTransform{
    LocationTransform * beforeLocation = [[LocationTransform alloc] initWithLatitude:116.245571 andLongitude:40.076428];
    //百度转化为GPS
    LocationTransform * afterLocation = [beforeLocation transformFromBDToGPS];
    NSLog(@"转化后:%f, %f", afterLocation.latitude, afterLocation.longitude);
    //    <wpt lat="40.075199" lon="116.239505">
}

@end

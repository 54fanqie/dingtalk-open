//
//  HolidayMessage.h
//  dingtalk-open
//
//  Created by fanqie on 2021/2/7.
//  Copyright © 2021 番茄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HolidayMessage : NSObject
// true表示是节假日，false表示是调休
@property(nonatomic,assign) Boolean holiday;
// 只在调休下有该字段。true表示放完假后调休，false表示先调休再放假
@property(nonatomic,assign) Boolean after;
// 节假日的中文名。如果是调休，则是调休的中文名，例如'国庆前调休'
@property(nonatomic,strong) NSString * name;
// 薪资倍数，1表示是1倍工资
@property(nonatomic,strong) NSString * wage;
// 节假日的日期
@property(nonatomic,strong) NSString * date;
//表示当前时间距离目标还有多少天
@property(nonatomic,strong) NSString * rest;
// 只在调休下有该字段。表示调休的节假日
@property(nonatomic,strong) NSString * target;

- (void)convert:(NSDictionary*)dataSource;
@end

NS_ASSUME_NONNULL_END

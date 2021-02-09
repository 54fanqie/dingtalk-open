//
//  TimeDetailView.h
//  上班打卡
//
//  Created by fanqie on 2019/2/13.
//  Copyright © 2019 番茄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeDetailView : UIWindow
@property(nonatomic,strong) UILabel * currentTimeLab;

@property(nonatomic,strong) UILabel * setTimeLab;
@property(nonatomic,strong) UILabel * titlelabel;
- (void)showWithAnimation:(BOOL)animation;
@property(copy,nonatomic)void(^closeBlock)(void);//申明回调函数
@end

NS_ASSUME_NONNULL_END

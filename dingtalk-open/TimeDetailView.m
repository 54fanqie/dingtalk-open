//
//  TimeDetailView.m
//  上班打卡
//
//  Created by fanqie on 2019/2/13.
//  Copyright © 2019 番茄. All rights reserved.
//

#import "TimeDetailView.h"

@interface TimeDetailView()
@property(nonatomic,strong)UIView *contentView;
@end


static TimeDetailView *singleInstance;

@implementation TimeDetailView

-(instancetype)init
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        self.windowLevel = UIWindowLevelAlert - 1;
        
        
        UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 50,[UIScreen mainScreen].bounds.size.width, 100)];
        topView.backgroundColor = [UIColor clearColor];
        [self addSubview:topView];
        
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 0, 260, 70)];
        imageView.image = [UIImage imageNamed:@"dangandai-titbg.png"];
        [imageView setCenter:CGPointMake(topView.bounds.size.width / 2, 35 )];
        [topView addSubview:imageView];
        
        self.titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, topView.frame.size.width, 25)];
        self.titlelabel.textAlignment = NSTextAlignmentCenter;
        self.titlelabel.font = [UIFont boldSystemFontOfSize:20];
        self.titlelabel.text = @"上班时间";
        self.titlelabel.textColor = [UIColor blackColor];
        [topView addSubview:self.titlelabel];
        
        
        self.setTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, topView.frame.size.width, 30)];
        self.setTimeLab.textAlignment = NSTextAlignmentCenter;
        self.setTimeLab.text = @"00:00";
        self.setTimeLab.font = [UIFont boldSystemFontOfSize:30];
        self.setTimeLab.textColor = [UIColor blackColor];
        [topView addSubview:self.setTimeLab];
        
        
        //关闭按钮
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(topView.frame.size.width - 50, 5,30,30);
        [button setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(hideWithAnimation) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:button];
        
        
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
        _contentView.backgroundColor = [UIColor colorWithRed:233/255.0 green:96/255.0 blue:78/255.0 alpha:1.0];
        _contentView.layer.cornerRadius = 120;
        _contentView.layer.masksToBounds = YES;
        [_contentView setCenter:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height /2 )];
        [self addSubview:_contentView];
        
        
        
        self.currentTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, _contentView.frame.size.width, 100)];
        self.currentTimeLab.textAlignment = NSTextAlignmentCenter;
        self.currentTimeLab.text = @"00:00:00";
        self.currentTimeLab.font = [UIFont systemFontOfSize:18];
        self.currentTimeLab.textColor = [UIColor whiteColor];
        self.currentTimeLab.numberOfLines=0;
        [self.currentTimeLab setCenter:CGPointMake(_contentView.bounds.size.width / 2, _contentView.bounds.size.height /2 )];
        [_contentView addSubview:self.currentTimeLab];
    
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.currentTimeLab.frame)-30, _contentView.frame.size.width, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:26];
        label.text = @"当前时间";
        label.textColor = [UIColor whiteColor];
        [_contentView addSubview:label];
        
        
        
        //          //触摸事件：弹出视图消失
        //        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideWithAnimation)];
        //        [self addGestureRecognizer:tap];
        //
        //        UITapGestureRecognizer *other = [[UITapGestureRecognizer alloc] init];
        //        [_contentView addGestureRecognizer:other];
        //
        //        singleInstance = self;
        
    }
    return self;
}

-(void)hideWithAnimation
{
    [self hideWithAnimation:YES];
    self.closeBlock();
}

- (void)showWithAnimation:(BOOL)animation
{
    [self makeKeyAndVisible];
    
    [UIView animateWithDuration:animation ? 0.3 : 0
                     animations:^{
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)hideWithAnimation:(BOOL)animation
{
    [UIView animateWithDuration:animation ? 0.3 : 0
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         singleInstance = nil;
                     }];
}

- (void)dealloc
{
    [self resignKeyWindow];
}

@end

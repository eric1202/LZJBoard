/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#import "UIViewController+HUD.h"
#import "MBProgressHUD.h"
#import <objc/runtime.h>
#import "UIView+Common.h"
#import <CoreLocation/CoreLocation.h>

static const void *HttpRequestHUDKey = &HttpRequestHUDKey;

@implementation UIViewController (HUD)

- (MBProgressHUD *)HUD{
    return objc_getAssociatedObject(self, HttpRequestHUDKey);
}

- (void)setHUD:(MBProgressHUD *)HUD{
    objc_setAssociatedObject(self, HttpRequestHUDKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showHudInView:(UIView *)view hint:(NSString *)hint{
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.labelText = hint;
    [view addSubview:HUD];
    [HUD show:YES];
    [self setHUD:HUD];
}

- (void)showHint:(NSString *)hint {
    if ([hint isEqualToString:@"录音没有开始"]) {
        NSLog(@"dd");
    }
    
    //显示提示信息
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.yOffset = IS_IPHONE_5?200.f:150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.8];
}

- (void)showHint:(NSString *)hint yOffset:(float)yOffset {
    //显示提示信息
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];

    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.yOffset = IS_IPHONE_5?200.f:150.f;
    hud.yOffset += yOffset;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.5];
}

- (void)hideHud{
    
    [[self HUD] hide:YES];
}

+(void)showHudWithImageName:(NSString *)imageName content:(NSString *)string inViewController:(UIViewController *)vc{
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:vc.view];
    hud.mode = MBProgressHUDModeCustomView;
    hud.frame = CGRectMake(150, 200, 100,100);
    
    UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
   
    UIImageView *imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    imageV.frame = CGRectMake(0, 0, 40, 40);
    imageV.center = CGPointMake(container.center.x, 40);
    [container addSubview:imageV];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, imageV.selfMaxY +10, 100, 20)];
    label.text = string;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    [container addSubview:label];
    
    hud.customView = container;
    [vc.view addSubview:hud];
    
    [hud show:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hide:YES afterDelay:1.0f];
    });

}

- (void)checkOpenSystemSetting
{
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)) {
            //定位功能可用，开始定位
        }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        NSLog(@"用户没有开启定位");
        UIAlertController *alt = [UIAlertController alertControllerWithTitle:@"未开启定位" message:@"打开定位获取更好的体验" preferredStyle:(UIAlertControllerStyleAlert)];
        [alt addAction:[UIAlertAction actionWithTitle:@"好的" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [alt dismissViewControllerAnimated:NO completion:nil];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        
        [alt addAction:[UIAlertAction actionWithTitle:@"不" style:(UIAlertActionStyleCancel) handler:nil]];
        [self presentViewController:alt animated:YES completion:nil];
        
    }
}

@end

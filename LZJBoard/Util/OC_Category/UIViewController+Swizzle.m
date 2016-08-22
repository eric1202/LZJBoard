//
//  UIViewController+Swizzle.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UIViewController+Swizzle.h"
#import "ObjcRuntime.h"


@implementation UIViewController (Swizzle)


- (void)customViewWillDisappear:(BOOL)animated {
//    返回按钮
    if (!self.navigationItem.backBarButtonItem
            && self.navigationController.viewControllers.count > 1) {//设置返回按钮(backBarButtonItem的图片不能设置；如果用leftBarButtonItem属性，则iOS7自带的滑动返回功能会失效)
        self.navigationItem.backBarButtonItem = [self backButton];
    }
    [self customViewWillDisappear:animated];
}


#pragma mark BackBtn M

- (UIBarButtonItem *)backButton {
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
//    temporaryBarButtonItem.image = [UIImage imageNamed:@"heyz_chat_back"];
    temporaryBarButtonItem.title = @"";
    temporaryBarButtonItem.tintColor = [UIColor clearColor];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    temporaryBarButtonItem.target = self;
//    if ([UINavigationBar instancesRespondToSelector:@selector(setBackIndicatorImage:)]) {
//        [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"heyz_chat_back"]];
//        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"heyz_chat_back"]];
//    }
//    NSDictionary*textAttributes;
//    if ([temporaryBarButtonItem respondsToSelector:@selector(setTitleTextAttributes:forState:)]){
//        textAttributes = @{
////                           NSFontAttributeName: [UIFont boldSystemFontOfSize:kBackButtonFontSize],
//                           NSForegroundColorAttributeName: [UIColor whiteColor],
//                           };
//        
//        [[UIBarButtonItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
//    }
    temporaryBarButtonItem.action = @selector(goBack_Swizzle);
    return temporaryBarButtonItem;
}

- (void)goBack_Swizzle {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

void swizzleAllViewController() {
//    Swizzle([UIViewController class], @selector(viewDidAppear:), @selector(customViewDidAppear:));
    Swizzle([UIViewController class], @selector(viewWillDisappear:), @selector(customViewWillDisappear:));
//    Swizzle([UIViewController class], @selector(viewWillAppear:), @selector(customviewWillAppear:));


    
}
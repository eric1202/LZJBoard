//
//  User.m
//  LZJBoard
//
//  Created by Heyz on 16/8/22.
//  Copyright © 2016年 LZJ. All rights reserved.
//

#import "User.h"

@implementation User

+(instancetype)currentUser{
    static User * instance = nil;
    static dispatch_once_t predict;
    dispatch_once(&predict, ^{
        instance = [[User alloc] init];
    });
    return instance;
}

-(void)getRandomName{
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"currentUserName"]){
        [User currentUser].name = [[NSUserDefaults standardUserDefaults]objectForKey:@"currentUserName"];
        return;
    }
    NSError*error;
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"englishName"ofType:@"json"];
    //根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    //格式化成json数据
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&error];
    
//    NSLog(@"jsonobjec : %@\n %@",jsonObject,error);
    NSArray *males = jsonObject[@"name1"];
    NSInteger count = males.count;
    NSInteger r = arc4random_uniform(count-1);
    
    [User currentUser].name = males[r];
    [[NSUserDefaults standardUserDefaults]setObject:[User currentUser].name forKey:@"currentUserName"];
    
}
@end

//
//  User.h
//  LZJBoard
//
//  Created by Heyz on 16/8/22.
//  Copyright © 2016年 LZJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSNumber *sex;

+(instancetype)currentUser;

-(void)getRandomName;

@end

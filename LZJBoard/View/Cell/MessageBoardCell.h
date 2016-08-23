//
//  MessageBoardCell.h
//  LZJBoard
//
//  Created by Heyz on 16/8/19.
//  Copyright © 2016年 LZJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCell.h"
@interface MessageBoardCell : BaseCell
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;

@property (weak, nonatomic) IBOutlet UILabel *contentLbl;
@end

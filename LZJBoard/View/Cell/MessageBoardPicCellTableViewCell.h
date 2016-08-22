//
//  MessageBoardPicCellTableViewCell.h
//  LZJBoard
//
//  Created by Heyz on 16/8/22.
//  Copyright © 2016年 LZJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageBoardPicCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;

@end

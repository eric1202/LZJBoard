//
//  MessageBoardPicCellTableViewCell.m
//  LZJBoard
//
//  Created by Heyz on 16/8/22.
//  Copyright © 2016年 LZJ. All rights reserved.
//

#import "MessageBoardPicCellTableViewCell.h"
#import "SJAvatarBrowser.h"
@implementation MessageBoardPicCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.imageV.layer.cornerRadius = 5;
    self.imageV.layer.masksToBounds = YES;
    self.imageV.userInteractionEnabled = YES;
    [self.imageV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(show:)]];
}

- (void)show:(UITapGestureRecognizer *)tap{
    
    if ([tap.view isKindOfClass:[UIImageView class]]) {
        [SJAvatarBrowser showImage:tap.view];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

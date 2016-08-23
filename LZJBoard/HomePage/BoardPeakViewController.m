//
//  BoardPeakViewController.m
//  LZJBoard
//
//  Created by Heyz on 16/8/23.
//  Copyright © 2016年 LZJ. All rights reserved.
//

#import "BoardPeakViewController.h"
#import "UIImageView+WebCache.h"
#import "UIView+Common.h"
@interface BoardPeakViewController ()
@property (strong,nonatomic) UILabel *nameLbl;
@property (strong,nonatomic) UILabel *contentLbl;

@property (strong,nonatomic) UIImageView *imageView;
@end

@implementation BoardPeakViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"记录详情";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.nameLbl];
    self.nameLbl.text = _board[@"fromUserName"];
    
    [self.view addSubview:self.contentLbl];
    self.contentLbl.text = _board[@"content"];
    
    if (_board[@"fileURL"]) {
        [self.view addSubview:self.imageView];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:_board[@"fileURL"]]];

    }
}


-(UILabel *)nameLbl{
    if (!_nameLbl) {
        _nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 300, 30)];
        _nameLbl.textAlignment = NSTextAlignmentCenter;
        _nameLbl.center = CGPointMake(self.view.center.x, 50);
        
    }
    
    return _nameLbl;
}

- (UILabel *)contentLbl{
    if (!_contentLbl) {
        _contentLbl = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, self.view.selfW-40, 100)];
        _contentLbl.textColor = [UIColor grayColor];
        _contentLbl.textAlignment = NSTextAlignmentCenter;
        _contentLbl.center = CGPointMake(self.view.center.x, self.nameLbl.selfMaxY +100);
        
    }
    
    return _contentLbl;
}

-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 300, 300)];
        
        _imageView.center = CGPointMake(self.view.center.x, self.contentLbl.selfMaxY + 180);
        
    }
    
    return _imageView;
}

-(NSArray<id<UIPreviewActionItem>> *)previewActionItems{
    return @[ [UIPreviewAction actionWithTitle:@"查看详情" style:(UIPreviewActionStyleDefault) handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
}



@end
